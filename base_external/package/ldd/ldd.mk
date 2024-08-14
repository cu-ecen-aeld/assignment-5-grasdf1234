
##############################################################
#
# LDD Package
#
##############################################################

LDD_VERSION = 7f0e347c4c0aa505d1d3bfe6f815ccdf87beb320
LDD_SITE = git@github.com:cu-ecen-aeld/assignment-7-grasdf1234.git
LDD_SITE_METHOD = git
LDD_MODULE_SUBDIRS = scull misc-modules

$(eval $(kernel-module))
$(eval $(generic-package))