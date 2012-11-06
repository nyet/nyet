use v5.10.1;
use Net::SSLeay;

#print Net::SSLeay::randomize();

#say Net::SSLeay::RAND_egd('lsusanto-h2:708');

#say Net::SSLeay::RAND_egd_bytes('localhost:708', 0x02);



$Net::SSLeay::trace=1; 

print Net::SSLeay::randomize();