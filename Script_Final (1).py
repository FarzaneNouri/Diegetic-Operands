import psutil
import time
from pythonosc import udp_client
from pythonosc import osc_message_builder
from pythonosc.osc_message_builder import OscMessageBuilder


#----------------- IP and Port ----------------
#ip="127.0.0.1"
ip="169.254.133.203"
port=2500

#----------------- Define OSC addresses ----------------
address="/wek/inputs"

#----------------- Messages ----------------
#message1: RAM used percentage
#message2: RAM used in GB
#message3: CPU used percentage

#---- network ----------------
#message4: Network: bytes sent
#message5: Network: bytes received
#message6: Network: bytes received
#message7: Network: packets received

#----------------- SuperCollider OSC addresses ----------------
#message8: SuperCollider CPU: time spent in user mode
#message9: SuperCollider CPU: time spent in kernel mode
#message10: SuperCollider CPU Usage: Percentage
#message11: SuperCollider Ram Usage: Resident Set Size
#message12: SuperCollider Ram: Virtual Memory Size

#----------------- Battery and Power Data ---------------
#address13: Battery Percentage
#address14: Power_plugged 1 or zero
#address15: Power Secounds Left

#----------------- Super Collider Process Name ----------------
pname="SuperCollider"




client = udp_client.SimpleUDPClient(ip, port)

def find_procs_by_name(name):
    ls = []
    for p in psutil.process_iter(['pid', 'name']):
        if p.info['name'] == name:
            ls.append(p)
    return ls

ls=find_procs_by_name(pname)

def get_power_consumption():
    try:
        battery = psutil.sensors_battery()

        if battery is not None:
            percent = battery.percent
            power_plugged = 1 if battery.power_plugged else 0
            message13=percent
            message14=power_plugged
            message15=battery.secsleft
            print(f"Battery Percent: {percent}%")
            print(f"Power Plugged: {power_plugged}")

    except Exception as e:
        print(f"Error: {e}")



def main_function(): 
	message8=0
	message9=0
	message10=0
	message11=0
	message12=0
	message13=-1
	message14=-1
	message15=-1

	msg_builder = OscMessageBuilder(address)
	cpup=psutil.cpu_percent(0.0)
	#print('The CPU usage is: ', cpup)

	# Getting % usage of virtual_memory
	ramg=psutil.virtual_memory()[2]
	#print('RAM memory % used:',ramg )
	# Getting usage of virtual_memory in GB ( 4th field)
	ramp=psutil.virtual_memory()[3]/1000000000
	#print('RAM Used (GB):', ramp)

	#---- network ----
	netbs=psutil.net_io_counters()[0]/1000000
	#print('Network: bytes sent:', psutil.net_io_counters()[0])
	netbr=psutil.net_io_counters()[1]/1000000
	#print('Network: bytes received:', psutil.net_io_counters()[1])
	netps=psutil.net_io_counters()[2]/1000000
	#print('Network: packets sent:', psutil.net_io_counters()[2])
	netpr=psutil.net_io_counters()[3]/1000000
	#print('Network: packets received:', psutil.net_io_counters()[3])
	#psutil.pids()
	#for proc in psutil.process_iter(['pid', 'name', 'username']):
	#	print(proc.info)

	#ls=find_procs_by_name(pname)

	if bool(ls):
		p = psutil.Process(ls[0].info['pid'])
		print(p.cpu_times())
		message8 = p.cpu_times()[0]
		message9 = p.cpu_times()[1]
		sccpp=p.cpu_percent(interval=0.1)
		print(sccpp)
		message10 = sccpp
		print(p.memory_info())
		message11 = p.memory_info()[0]
		message12 = p.memory_info()[1]


	else:
		print("----------------SuperCollider Process Can't be found--------------------")

	get_power_consumption()
	# Create OSC messages
	message1 = ramp
	message2 = ramg
	message3 = cpup
	message4 = netbs
	message5 = netbr
	message6 = netps
	message7 = netpr

	msg_builder.add_arg(message1, 'f')
	msg_builder.add_arg(message2, 'f')
	msg_builder.add_arg(message3, 'f')
	msg_builder.add_arg(message4, 'f')
	msg_builder.add_arg(message5, 'f')
	msg_builder.add_arg(message6, 'f')
	msg_builder.add_arg(message7, 'f')
	msg_builder.add_arg(message8, 'f')
	msg_builder.add_arg(message9, 'f')
	msg_builder.add_arg(message10, 'f')
	msg_builder.add_arg(message11, 'f')
	msg_builder.add_arg(message12, 'f')
	msg_builder.add_arg(message13, 'f')
	msg_builder.add_arg(message14, 'f')
	msg_builder.add_arg(message15, 'f')

	#Sending OSC messages
	osc_message = msg_builder.build()
	client.send(osc_message)

while True:
    main_function()
    time.sleep(3.9)
