local modules = fs.list("VHMD/modules")
shell.run("rm VHMD/")
shell.run("cd /")
shell.run("mkdir VHMD")
shell.run("cd VHMD")
shell.run("mkdir modules")
shell.run("wget https://raw.githubusercontent.com/Starlight-CC/VHMD/refs/heads/main/VHMD/init.lua")
shell.run("wget https://raw.githubusercontent.com/Starlight-CC/VHMD/refs/heads/main/VHMD/installModule.lua")
shell.run("wget https://raw.githubusercontent.com/Starlight-CC/VHMD/refs/heads/main/VHMD/update.lua")
for i,v in ipairs(modules) do
  shell.run("wget https://raw.githubusercontent.com/Starlight-CC/VHMD/refs/heads/main/VHMD/modules/"..v)
end
shell.run("cd /")
shell.run("VHMD/init.lua")
