{
  config,
  lib,
  pkgs,
}:
''
  import json
  from os import path
  import subprocess


  locks = {}

  DEEPEN_STEP = ${toString config.repos.depth.deepen.base}
  DEEPEN_STEP_MERGE = ${toString config.repos.depth.deepen.merge}
  INITIAL_DEPTH = ${toString config.repos.depth.initial.base}
  INITIAL_DEPTH_MERGE = ${toString config.repos.depth.initial.merge}


  def check_hash(remote, ref, repo_path):
      result = git_cmd("-C", repo_path, "ls-remote", remote, ref, capture_output=True)
      if not result.stdout:
          raise Exception("No output from ls-remote")
      return result.stdout[:40]


  def have_commit(repo_path, commit):
      return git_cmd(
          "-C", repo_path, "rev-parse", "--verify", commit, may_fail=True
      ).returncode == 0


  def is_hash(string):
      if len(string) != 40:
          return False
      try:
          int(string, 16)
          return True
      except ValueError:
          return False


  def git_cmd(*args, may_fail=False, **kwargs):
      #print("git_cmd", args)
      result = subprocess.run(["${pkgs.git}/bin/git"] + list(args), text=True, **kwargs)
      if not may_fail and result.returncode != 0:
          raise Exception(f"Git command failed with exit code {result.returncode}: " + str(args))
      return result


  def git_lock(repo, remote, ref, repo_path):
      if is_hash(ref):
          return ref

      # Use the lock that is already established when available
      if repo in locks and remote in locks[repo] and ref in locks[repo][remote]:
          return locks[repo][remote][ref]

      # Otherwise, establish a lock now
      hash = check_hash(remote, ref, repo_path)
      if repo not in locks:
          locks[repo] = {}
      if remote not in locks[repo]:
          locks[repo][remote] = {}
      locks[repo][remote][ref] = hash
      save_locks()
      return hash


  def load_locks():
      global locks
      if not path.exists("repos.lock"):
          return

      with open("repos.lock", "r") as f:
          locks = json.load(f)


  def remote_url(repo_path, remote):
      result = git_cmd(
          "-C",
          repo_path,
          "remote",
          "get-url",
          remote,
          may_fail=True,
          capture_output=True
      )
      if result.returncode == 2:
          return None
      return result.stdout


  def repo_aggregate(name, url, ref, remotes, merges):
      repo_initialize(name, url, ref, remotes, len(merges) > 0)
      for remote, merge_ref in merges:
          repo_merge(name, remote, merge_ref, ref)


  def repo_initialize(name, url, ref, remotes, has_merges):
      commit = None
      repo_path = path.join("wax/repos", name)
      if not path.isdir(repo_path):
          depth = not has_merges and 1 or INITIAL_DEPTH
          git_cmd("clone", "--depth", str(depth), url, "-b", ref, repo_path)
          git_cmd("-C", repo_path, "remote", "add", name, url)
          commit = git_lock(name, name, ref, repo_path)
      elif not is_hash(ref):
          commit = git_lock(name, name, ref, repo_path)
      if commit:
          if git_cmd(
              "-C", repo_path, "reset", "--hard", commit, may_fail=True, stderr=subprocess.DEVNULL
          ).returncode == 128:
              repo_reset_flexible(commit, repo_path)

      # Add the remotes, and make sure the URL's are updated
      for name, url in remotes.items():
          existing_url = remote_url(repo_path, name)
          if existing_url:
              existing_url = existing_url.strip()
          if existing_url != url:
              git_cmd(
                  "-C", repo_path, "remote", "remove", name, may_fail=True,
                  stderr=subprocess.DEVNULL
              )
              git_cmd("-C", repo_path, "remote", "add", name, url)


  def repo_deepen(repo_path, count):
      # FIXME: I can't really get the output of this command for some reason.
      # If I would have the output, I could check if we downloaded any commits.
      # If we didn't download any commits, we can escape the loop, assuming there are no older
      # commits to gather anymore.
      git_cmd("-C", repo_path, "fetch", "--deepen", str(count), capture_output=False)


  def repo_reset_flexible(commit, repo_path):
      for i in range(21):
          exit_code = git_cmd(
              "-C", repo_path, "reset", "--hard", commit, may_fail=True, stderr=subprocess.DEVNULL
          ).returncode
          if exit_code != 128:
              if exit_code == 0:
                  return
              else:
                  raise Exception(f"Git reset failed with exit code {exit_code}")
          if i != 20:
              repo_deepen(repo_path, DEEPEN_STEP)
          else:
              print(
                  f"Going to download the complete git history for {repo_path}, because commit "
                  f"{commit} could not be found by deepening 20 times.\n"
                  "Is the commit stored in \"repos.lock\" still valid?"
              )
              git_cmd("-C", repo_path, "fetch")


  def repo_merge(repo, remote, ref, base_ref):
      def check_ancestor(repo_path):
          result = git_cmd(
              "-C", repo_path, "merge-base", base_ref, remote + '/' + ref, may_fail=True
          )
          return result.returncode

      repo_path = path.join("wax/repos", repo)
      commit = git_lock(repo, remote, ref, repo_path)
      returncode = check_ancestor(repo_path)
      if returncode == 128:
          git_cmd("-C", repo_path, "fetch", "--depth", str(INITIAL_DEPTH_MERGE), remote, ref)
      elif returncode != 0:
          raise Exception("Invalid returncode for merge-base: " + str(returncode))

      # Deepen the repository until we have found a common ancestor, meaning we can perform the
      # merge
      ancestor_found = False
      for i in range(20):
          returncode = check_ancestor(repo_path)
          if returncode == 0:
              ancestor_found = True
              break
          elif returncode != 1:
              raise Exception("Invalid returncode for merge-base: " + str(returncode))
          repo_deepen(repo_path, DEEPEN_STEP_MERGE)
          git_cmd("-C", repo_path, "fetch", "--deepen", str(DEEPEN_STEP_MERGE), remote, ref)

      # If no common ancestor were found, lets download the full history as a last resort.
      if not ancestor_found:
          git_cmd("-C", repo_path, "fetch")
          git_cmd("-C", repo_path, "fetch", remote, ref)

      # Check if we have the commit we need to merge in, otherwise, pull it in
      # FIXME: The merge command is giving merge conflicts while pull is not. Investigate.
      #new_branch_name = f"wax_merge_{remote}_{ref}"
      #git_cmd("-C", repo_path, "branch", "-f", new_branch_name, commit)
      #return new_branch_name
      git_cmd("-C", repo_path, "pull", "--no-edit", remote, commit)


  def save_locks():
      with open("repos.lock", "w") as f:
          json.dump(locks, f, indent=2)


  def main():
      load_locks()
      subprocess.run(["${pkgs.coreutils}/bin/mkdir", "-p", "wax/repos"])

''
+ lib.strings.concatStrings (
  lib.attrsets.mapAttrsToList (
    repoName: repoConfig:
    let
      repoRef = if repoConfig ? ref then repoConfig.ref else config.repos.defaultRef;
      repoUrl =
        if repoConfig ? url then
          repoConfig.url
        else if repoName == "odoo" then
          "https://github.com/OCA/OCB.git"
        else
          "https://github.com/OCA/" + repoName + ".git";
    in
    "    remotes = {\"${repoName}\": \"${repoUrl}\", "
    + (lib.strings.concatStringsSep ", " (
      lib.attrsets.mapAttrsToList (remoteName: remoteUrl: "\"${remoteName}\": \"${remoteUrl}\"") (
        repoConfig.remotes or { }
      )
    ))
    + "}\n    merges = ["
    + (lib.strings.concatStringsSep ", " (
      if repoConfig ? merges then
        if builtins.isAttrs repoConfig.merges then
          lib.attrsets.mapAttrsToList (
            remoteName: remoteRef: "(\"${remoteName}\", \"${remoteRef}\")"
          ) repoConfig.merges
        else if builtins.isList repoConfig.merges then
          lib.lists.forEach repoConfig.merges (x: "(\"${builtins.elemAt x 0}\", \"${builtins.elemAt x 1}\")")
        else
          [ "" ]
      else
        [ "" ]
    ))
    + "]\n"
    + "    repo_aggregate(\"${repoName}\", \"${repoUrl}\", \"${repoRef}\", remotes, merges)\n"
  ) config.repos.spec
)
+ "\n\nmain()\n"
