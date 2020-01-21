import subprocess


execname = "add_grid_arg" 

ch_blockSize = ["1","2","4","8" ,"16" ,"32","64", "128", "256"] 

ch_numBlocks = ["1","2","4","8" ,"16" ,"32","64", "128", "256", "512", "1024", "2048", "4096"]


for bS in ch_blockSize:
	print ("PROFILE RESULTS for blockSize = " + bS + " and numBlocks = " + "4096" + "\n")
	bashCommand = "nvprof ./" + execname + " "+ bS + " " + "4096"
	output = subprocess.check_output(['bash','-c', bashCommand])
	print(output)


for nB in ch_numBlocks:
	print ("PROFILE RESULTS for blockSize = " +"256"+" and numBlocks = " + nB + "\n")
	bashCommand = "nvprof ./" + execname + " " + "256" + " " + nB
	output = subprocess.check_output(['bash','-c', bashCommand])
	print(output)

