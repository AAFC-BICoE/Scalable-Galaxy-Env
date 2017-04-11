# Scalable-Galaxy-Env

The heat template, currently called hello_world.yaml needs to be placed on a controller node for your environment. Currently untested with the Horizon dashboard.

Requirements:
* It isn't necessary that your instances have DNS resolution but it makes some things easier, such as reducing the time needed to log into your Openstack instances.
1. Public-private key pair available within Openstack. The private key should be available on the controller from which you put the heat template on. The correct name of the public key should be updated in the heat template. (Insert line number here)

2. You need a private and public network accessible from Openstack. Obtain the net-ids for both and substitute in the parmeters section of the heat template (Line 30, 34, 38). To get the net-ids, on the controller node type "neutron net-list" and "neutron subnet-list". The private network also needs to be changed in the ansible playbook (Line 13).

3. You will need an Ubuntu image, preferably 14.04. Here is a link to a website where you can get the image for free: http://releases.ubuntu.com/14.04/. The name of the image needs to be changed in the heat template. (Line 15, 20 and Line 11 respectively.)

4. You will need to change the relevant information for your Openstack account. Since ansible will take care of creating and deleting instances, it needs Openstack credentials to do this, and therefore an rc file. It is easiest to just provide the relevant information on the file rather than transfer a copy of your openrc file to the web server. Here are the variables that will need to be changed in the web server user_data paramter: OS_USERNAME, OS_PASSWORD, OS_TENANT_NAME, OS_AUTH_URL, OS_REGION_NAME, ENDPOINT_TYPE, OS_INTERFACE, OS_IDENTITY_API_VERSION. Again these parameter values can be found from your admin-openrc file on the Openstack Horizon dashboard. It is under Access & Security -> API Access -> Download Openstack RC File.
