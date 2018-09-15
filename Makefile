PACKAGES = \
	libestr \
	perl-jcode \
	perl-unicode-map \
	perl-unicode-map8 \
	perl-unicode-maputf8 \
	perl-unicode-string \
	smbldap-tools \
	authselect

CLEAN_PACKAGES = $(addprefix clean-,$(PACKAGES))

MAINTAINER_CLEAN_PACKAGES = $(addprefix maintainer-clean-,$(PACKAGES))

BACKUP_PACKAGES = $(addprefix backup-,$(PACKAGES))

BACKUP_DIR = backup

define BUILD_PACKAGE
$(1) :
	if [ ! -e $(1) ]; then git clone https://aur.archlinux.org/$(1).git; fi
	-cd $(1) && makepkg --skippgpcheck V=1
endef

define CLEAN_PACKAGE
clean-$(1) :
	if [ -e $(1) ]; then \
		rm -rf $(1)/pkg; \
		rm -rf $(1)/src; \
	fi
endef

define MAINTAINER_CLEAN_PACKAGE
maintainer-clean-$(1) :
	-for f in $(1)/*.tar.*; do \
		[ -e "$$$$f" ] && rm -f "$$$$f" ; \
	done
endef

define BACKUP_PACKAGE
backup-$(1) :
	mkdir $(BACKUP_DIR)/$(1)
	cp $(1)/PKGBUILD $(BACKUP_DIR)/$(1)/
	-for f in $(1)/*.patch; do \
		[ -e "$$$$f" ] && cp "$$$$f" $(BACKUP_DIR)/$(1)/ ; \
	done
endef


all : $(PACKAGES)

backup : backup-init $(BACKUP_PACKAGES)

clean : $(CLEAN_PACKAGES)

maintainer-clean : $(MAINTAINER_CLEAN_PACKAGES)

test :
	echo $(CLEAN_PACKAGES)

$(foreach PACKAGE,$(PACKAGES),$(eval $(call BUILD_PACKAGE,$(PACKAGE))))

$(foreach PACKAGE,$(PACKAGES),$(eval $(call CLEAN_PACKAGE,$(PACKAGE))))

$(foreach PACKAGE,$(PACKAGES), \
	$(eval $(call MAINTAINER_CLEAN_PACKAGE,$(PACKAGE))))

$(foreach PACKAGE,$(PACKAGES),$(eval $(call BACKUP_PACKAGE,$(PACKAGE))))

backup-init :
	rm -rf $(BACKUP_DIR)
	mkdir $(BACKUP_DIR)
	cp Makefile $(BACKUP_DIR)/

.PHONY : \
	$(PACKAGES)

