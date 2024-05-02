#!/bin/bash
#var
export USERNAME=user1
export PASSWORD=user1

#Adding user to use serial console
useradd $USERNAME
echo $USERNAME:$PASSWORD | chpasswd
usermod -aG google-sudoers $USERNAME

#Web server install 
apt-get update
apt-get install -y apache2
cat <<EOF > /var/www/html/index.html
<html><body><p>(Computers) an electronic device for performing
      calculations automatically. It consists of a clock to
      provide voltage pulses to synchronize the operations of
      the devices within the computer, a central processing
      unit, where the arithmetical and logical operations are
      performed on data, a random-access memory, where the
      programs and data are stored for rapid access, devices to
      input data and output results, and various other
      peripheral devices of widely varied function, as well as
      circuitry to support the main operations.</p></body></html>
EOF

#definition retrieved from curl "dict://dict.org/d:computer"