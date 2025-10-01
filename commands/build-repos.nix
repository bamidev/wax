{ config, lib, pkgs }: ''
  import json
  from os import path
  import subprocess


  locks = {}

  DEEPEN_STEP = 500
  DEEPEN_STEP_BRANCH = 50


  def check_hash(remote, ref, repo_path):
      result = git_cmd("-C", repo_path, "ls-remote", remote, ref, capture_output=True)
      if not result.stdout:
          raise Exception("No output from ls-remote")
      return result.stdout[:40]


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


  def repo_aggregate(name, url, ref, remotes, merges):
      repo_initialize(name, url, ref, remotes)
      for remote, merge_ref in merges:
          repo_merge(name, remote, merge_ref, ref)


  def repo_initialize(name, url, ref, remotes):
      commit = None
      repo_path = path.join("wax/repos", name)
      if not path.isdir(repo_path):
          git_cmd("clone", "--depth", "1", url, "-b", ref, repo_path)
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
          git_cmd(
              "-C", repo_path, "remote", "remove", name, may_fail=True, stderr=subprocess.DEVNULL
          )
          git_cmd("-C", repo_path, "remote", "add", name, url)


  def repo_reset_flexible(commit, repo_path):
      while True:
          git_cmd("-C", repo_path, "fetch", "--deepen", str(DEEPEN_STEP))
          exit_code = git_cmd(
              "-C", repo_path, "reset", "--hard", commit, may_fail=True, stderr=subprocess.DEVNULL
          ).returncode
          if exit_code != 128:
              if exit_code == 0:
                  return
              else:
                  raise Exception(f"Git reset failed with exit code {exit_code}")


  def repo_merge(repo, remote, ref, base_ref):
      repo_path = path.join("wax/repos", repo)
      commit = git_lock(repo, remote, ref, repo_path)
      git_cmd("-C", repo_path, "fetch", "--depth", str(20), remote, ref)

      # Deepen the repository until we have found a common ancestor, meaning we can perform the
      # merge
      while True:
          result = git_cmd(
              "-C", repo_path, "merge-base", base_ref, remote + "/" + ref, may_fail=True, capture_output=True
          )
          if result.returncode == 0:
              break
          elif result.returncode != 1:
              raise Exception("Invalid returncode for merge-base: " + str(result.returncode))
          git_cmd("-C", repo_path, "fetch", "--deepen", str(DEEPEN_STEP))
          git_cmd("-C", repo_path, "fetch", "--deepen", str(DEEPEN_STEP_BRANCH), remote, ref)

      git_cmd("-C", repo_path, "pull", "--no-edit", "--no-rebase", remote, commit)


  def save_locks():
      with open("repos.lock", "w") as f:
          json.dump(locks, f, indent=2)


  def main():
      load_locks()
      subprocess.run(["${pkgs.coreutils}/bin/mkdir", "-p", "wax/repos"])
  
      '' + lib.strings.concatStrings (
        lib.attrsets.mapAttrsToList (repoName: repoConfig:
          "    remotes = {\"${repoName}\": \"${repoConfig.url}\", " + (lib.strings.concatStringsSep ", " (
            lib.attrsets.mapAttrsToList (remoteName: remoteUrl:
              "\"${remoteName}\": \"${remoteUrl}\""
            ) (repoConfig.remotes or {})
          )) + "}\n    merges = [" + (lib.strings.concatStringsSep ", " (
            if repoConfig ? merges then
              if builtins.isAttrs repoConfig.merges then
                lib.attrsets.mapAttrsToList (remoteName: remoteRef:
                  "(\"${remoteName}\", \"${remoteRef}\")"
                ) repoConfig.merges
              else if builtins.isList repoConfig.merges then
                lib.lists.forEach repoConfig.merges (x:
                  "(\"${builtins.elemAt x 0}\", \"${builtins.elemAt x 1}\")"
                )
              else
                [""]
            else
              [""]
          )) + "]\n" +
  "    repo_aggregate(\"${repoName}\", \"${repoConfig.url}\", \"${repoConfig.ref}\", remotes, merges)\n") config.repos) +
  "\n\nmain()\n"
