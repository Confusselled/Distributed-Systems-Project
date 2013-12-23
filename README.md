Distributed-Systems-Project
===========================


This is my submission for the distributed systems project.

I have made one slight alteration for testing purposes. I have passed the port
number instead of the IP address, but still called it IP. This is due purely to 
fact I needed to test on a single machine.

The project is implemented across the files;
node: provides the interface and central operation
routing: maintains the routing table and gives functions for accessing and 
		adding nodes
message: provides methods for constructing each message type

The remaining files all named main or main_XXX were used for testing and 
instanciate a node and then perform some actions such as searching or 
indexing.
