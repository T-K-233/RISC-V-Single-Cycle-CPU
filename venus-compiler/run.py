import subprocess
import sys

filename = "a.s"

if len(sys.argv) > 1:
    filename = sys.argv[1]

venus_prog = ["java", "-jar", "venus-cs61c-sp20.jar", filename, "-d"]

proc = subprocess.run(venus_prog, stdout=subprocess.PIPE)

if proc.stdout[:2] != b"0x":
    raise FileNotFoundError(proc.stdout.decode("utf-8"))

result = proc.stdout.decode("utf-8").replace("0x", "")

tar_filename = "IMEM"
with open(tar_filename, "w") as f:
    f.write("v2.0 raw\n")
    f.write(result)

print("Finish assembling '{0}', output as '{1}'".format(filename, tar_filename))

