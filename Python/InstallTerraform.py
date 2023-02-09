import requests, os, zipfile, subprocess, sys, argparse

parser = argparse.ArgumentParser(
        description='sum the integers at the command line')
parser.add_argument('-i','--install_terraform',default="", type=str,help="Install terraform on windows", required=False)
parser.add_argument('-v','--tf_version', default="1.3.7",help='Enter terraform version',required=False)
args = parser.parse_args()

# Defining error check function

def CheckError(result):
    if  result.returncode == 0:
        result.stdout
    else:
        result.stderr

# Defining Terraform Install function

def InstallTerraform():
    if args.install_terraform == 'install':
        url =  "https://releases.hashicorp.com/terraform/" + args.tf_version + "/terraform_" + args.tf_version + "_windows_386.zip"
        r = requests.get(url)
        filename = url.split("/")[-1]
        print("\nDownloading " + filename + " from " + url + "\n")
        SaveUrl = os.path.join('C:', os.sep, 'Users', os.getlogin(), 'Documents', 'TerraInstall')
        if not os.path.exists(SaveUrl):
            os.mkdir(SaveUrl)
        SaveFile = os.path.join('C:', os.sep, 'Users', os.getlogin(), 'Documents', 'TerraInstall', filename)
        print("Storing " + filename + " to " + SaveFile + "\n")
        with open(SaveFile, 'wb') as f:
            # You will get the file in base64 as content
            f.write(r.content)

        ## Unzip the archive
        print("Unzipping the " + filename + " from " + SaveFile + " under " + SaveUrl + "\n")
        with zipfile.ZipFile(SaveFile,"r") as zip_ref:
            zip_ref.extractall(SaveUrl)

if args.install_terraform == "install":
    InstallTerraform()

if len(sys.argv) == 1:
    print("\nNo arguments supplied, please run -h with script to know more about options\n")
    sys.exit(0)
