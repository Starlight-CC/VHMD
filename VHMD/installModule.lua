local text = ""
print("Type module name")
local text=read()
local dir = shell.dir()
shell.run("cd /VHMD/modules")
shell.run("wget https://raw.githubusercontent.com/Starlight-CC/VHMD/refs/heads/main/VHMD/modules/"..text)
shell.run("cd /"..dir)