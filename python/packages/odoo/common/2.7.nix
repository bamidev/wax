# Odoo python packages pinned to the exact same version (and thus hash) across every odoo major
# version that runs on python 2.7 (currently 8, 9, and 10). Versions diverge here much more than
# in the later 3.x-era pairs, so only a handful of packages actually qualify; everything else
# stays in each odoo major version's own file.
{
  config,
  python,
  pythonDefaultPackages,
  ...
}:
let
  pythonPackage = python.pythonPackage pythonDefaultPackages;
in
{
  docutils = pythonPackage {
    pname = "docutils";
    version = "0.12";
    hash = "sha256-x9txeBCraWX2bIzwOYqYydjfmC2jm0zX8WKRHriVlvo=";
  };

  jcconv = pythonPackage {
    pname = "jcconv";
    version = "0.2.3";
    hash = "sha256-471Z0/sSm5UvhMZuYYer3biMx8KzyDsSaFoyVv07XlQ=";
  };

  markupsafe = pythonPackage {
    pname = "MarkupSafe";
    version = "0.23";
    hash = "sha256-pOwa/1m5WhS0XrLiN2GgF56YMZ2lp+t2tW6ozce4ccM=";
  };

  psycogreen = pythonPackage {
    pname = "psycogreen";
    version = "1.0";
    hash = "sha256-ms+my1NzvPHq8nyQTZjVnJ87sAZcuwBfg8zEUFWs6aE=";
  };

  psycopg2 = pythonPackage {
    pname = "psycopg2";
    version = "2.7.7";
    hash = "sha256-9FJtB4rt1Rh9BQiqX5oB6uakikcO1nhAbalLTNZSS34=";
    nativeBuildInputs = [ config.database.package.dev ];
  };

  pypdf = pythonPackage {
    pname = "pyPdf";
    version = "1.13";
    hash = "sha256-Ou3kw8nGrQfJjwWfkNsLCe04P3x5HEYQD2SeHKvaDjs=";
    pythonImportsCheck = [ "pyPdf" ];
  };

  python-chart = pythonPackage {
    pname = "Python-Chart";
    version = "1.39";
    hash = "sha256-2iCtEAIr8C40sOLVzk8sy2C1YwHKefq5frRqNl9/uSY=";
    pythonImportsCheck = [ "pychart" ];
  };

  python-openid = pythonPackage {
    pname = "python-openid";
    version = "2.2.5";
    hash = "sha256-ksUcPs7IRsvsSu/xH5/0cwPUpj+TsOasDsAqCR/tcO8=";
    pythonImportsCheck = [ "openid" ];
  };

  vatnumber = pythonPackage {
    pname = "vatnumber";
    version = "1.2";
    hash = "sha256-Tp6cq8/2B22N64o0ft/V0KuMqx7TRP2+XdSmEQovLHs=";
  };
}
