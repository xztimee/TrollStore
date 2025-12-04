TOPTARGETS := all clean update

$(TOPTARGETS): pre_build make_fastPathSign make_roothelper make_luisestore make_trollhelper_embedded make_trollhelper_package assemble_luisestore build_installer15 build_installer64e make_luisestore_lite

# CI build target without installers (requires InstallerVictim.ipa)
ci-build: pre_build ci_make_fastPathSign ci_make_roothelper ci_make_luisestore ci_make_trollhelper_embedded ci_make_trollhelper_package ci_assemble_luisestore ci_make_luisestore_lite

pre_build:
	@rm -rf ./_build 2>/dev/null || true
	@mkdir -p ./_build

make_fastPathSign:
	@$(MAKE) -C ./Exploits/fastPathSign $(MAKECMDGOALS)

ci_make_fastPathSign:
	@$(MAKE) -C ./Exploits/fastPathSign all

make_roothelper:
	@$(MAKE) -C ./RootHelper DEBUG=0 $(MAKECMDGOALS)

ci_make_roothelper:
	@$(MAKE) -C ./RootHelper DEBUG=0 all

make_luisestore:
	@$(MAKE) -C ./LuiseStore FINALPACKAGE=1 $(MAKECMDGOALS)

ci_make_luisestore:
	@$(MAKE) -C ./LuiseStore FINALPACKAGE=1 all

ifneq ($(MAKECMDGOALS),clean)

make_trollhelper_package:
	@$(MAKE) clean -C ./TrollHelper
	@cp ./RootHelper/.theos/obj/luisestorehelper ./TrollHelper/Resources/luisestorehelper
	@$(MAKE) -C ./TrollHelper FINALPACKAGE=1 package $(MAKECMDGOALS)
	@$(MAKE) clean -C ./TrollHelper
	@$(MAKE) -C ./TrollHelper THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1 package $(MAKECMDGOALS)
	@rm ./TrollHelper/Resources/luisestorehelper

ci_make_trollhelper_package:
	@$(MAKE) clean -C ./TrollHelper
	@cp ./RootHelper/.theos/obj/luisestorehelper ./TrollHelper/Resources/luisestorehelper
	@$(MAKE) -C ./TrollHelper FINALPACKAGE=1 package all
	@$(MAKE) clean -C ./TrollHelper
	@$(MAKE) -C ./TrollHelper THEOS_PACKAGE_SCHEME=rootless FINALPACKAGE=1 package all
	@rm ./TrollHelper/Resources/luisestorehelper

make_trollhelper_embedded:
	@$(MAKE) clean -C ./TrollHelper
	@$(MAKE) -C ./TrollHelper FINALPACKAGE=1 EMBEDDED_ROOT_HELPER=1 $(MAKECMDGOALS)
	@cp ./TrollHelper/.theos/obj/LuiseStorePersistenceHelper.app/LuiseStorePersistenceHelper ./_build/PersistenceHelper_Embedded
	@$(MAKE) clean -C ./TrollHelper
	@$(MAKE) -C ./TrollHelper FINALPACKAGE=1 EMBEDDED_ROOT_HELPER=1 LEGACY_CT_BUG=1 $(MAKECMDGOALS)
	@cp ./TrollHelper/.theos/obj/LuiseStorePersistenceHelper.app/LuiseStorePersistenceHelper ./_build/PersistenceHelper_Embedded_Legacy_arm64
	@$(MAKE) clean -C ./TrollHelper
	@$(MAKE) -C ./TrollHelper FINALPACKAGE=1 EMBEDDED_ROOT_HELPER=1 CUSTOM_ARCHS=arm64e $(MAKECMDGOALS)
	@cp ./TrollHelper/.theos/obj/LuiseStorePersistenceHelper.app/LuiseStorePersistenceHelper ./_build/PersistenceHelper_Embedded_Legacy_arm64e
	@$(MAKE) clean -C ./TrollHelper

ci_make_trollhelper_embedded:
	@$(MAKE) clean -C ./TrollHelper
	@$(MAKE) -C ./TrollHelper FINALPACKAGE=1 EMBEDDED_ROOT_HELPER=1 all
	@cp ./TrollHelper/.theos/obj/LuiseStorePersistenceHelper.app/LuiseStorePersistenceHelper ./_build/PersistenceHelper_Embedded
	@$(MAKE) clean -C ./TrollHelper
	@$(MAKE) -C ./TrollHelper FINALPACKAGE=1 EMBEDDED_ROOT_HELPER=1 LEGACY_CT_BUG=1 all
	@cp ./TrollHelper/.theos/obj/LuiseStorePersistenceHelper.app/LuiseStorePersistenceHelper ./_build/PersistenceHelper_Embedded_Legacy_arm64
	@$(MAKE) clean -C ./TrollHelper
	@$(MAKE) -C ./TrollHelper FINALPACKAGE=1 EMBEDDED_ROOT_HELPER=1 CUSTOM_ARCHS=arm64e all
	@cp ./TrollHelper/.theos/obj/LuiseStorePersistenceHelper.app/LuiseStorePersistenceHelper ./_build/PersistenceHelper_Embedded_Legacy_arm64e
	@$(MAKE) clean -C ./TrollHelper

assemble_luisestore:
	@cp ./RootHelper/.theos/obj/luisestorehelper ./LuiseStore/.theos/obj/LuiseStore.app/luisestorehelper
	@cp ./TrollHelper/.theos/obj/LuiseStorePersistenceHelper.app/LuiseStorePersistenceHelper ./LuiseStore/.theos/obj/LuiseStore.app/PersistenceHelper
	@export COPYFILE_DISABLE=1
	@tar -czvf ./_build/LuiseStore.tar -C ./LuiseStore/.theos/obj LuiseStore.app

ci_assemble_luisestore:
	@cp ./RootHelper/.theos/obj/luisestorehelper ./LuiseStore/.theos/obj/LuiseStore.app/luisestorehelper
	@cp ./TrollHelper/.theos/obj/LuiseStorePersistenceHelper.app/LuiseStorePersistenceHelper ./LuiseStore/.theos/obj/LuiseStore.app/PersistenceHelper
	@export COPYFILE_DISABLE=1
	@tar -czvf ./_build/LuiseStore.tar -C ./LuiseStore/.theos/obj LuiseStore.app

build_installer15:
	@mkdir -p ./_build/tmp15
	@unzip ./Victim/InstallerVictim.ipa -d ./_build/tmp15
	@cp ./_build/PersistenceHelper_Embedded_Legacy_arm64 ./_build/LuiseStorePersistenceHelperToInject
	@pwnify set-cpusubtype ./_build/LuiseStorePersistenceHelperToInject 1
	@ldid -s -K./Victim/victim.p12 ./_build/LuiseStorePersistenceHelperToInject
	APP_PATH=$$(find ./_build/tmp15/Payload -name "*" -depth 1) ; \
	APP_NAME=$$(basename $$APP_PATH) ; \
	BINARY_NAME=$$(echo "$$APP_NAME" | cut -f 1 -d '.') ; \
	echo $$BINARY_NAME ; \
	pwnify pwn ./_build/tmp15/Payload/$$APP_NAME/$$BINARY_NAME ./_build/LuiseStorePersistenceHelperToInject
	@pushd ./_build/tmp15 ; \
	zip -vrD ../../_build/TrollHelper_iOS15.ipa * ; \
	popd
	@rm ./_build/LuiseStorePersistenceHelperToInject
	@rm -rf ./_build/tmp15

build_installer64e:
	@mkdir -p ./_build/tmp64e
	@unzip ./Victim/InstallerVictim.ipa -d ./_build/tmp64e
	APP_PATH=$$(find ./_build/tmp64e/Payload -name "*" -depth 1) ; \
	APP_NAME=$$(basename $$APP_PATH) ; \
	BINARY_NAME=$$(echo "$$APP_NAME" | cut -f 1 -d '.') ; \
	echo $$BINARY_NAME ; \
	pwnify pwn64e ./_build/tmp64e/Payload/$$APP_NAME/$$BINARY_NAME ./_build/PersistenceHelper_Embedded_Legacy_arm64e
	@pushd ./_build/tmp64e ; \
	zip -vrD ../../_build/TrollHelper_arm64e.ipa * ; \
	popd
	@rm -rf ./_build/tmp64e

make_luisestore_lite:
	@$(MAKE) -C ./RootHelper DEBUG=0 LUISESTORE_LITE=1
	@rm -rf ./LuiseStoreLite/Resources/luisestorehelper
	@cp ./RootHelper/.theos/obj/luisestorehelper_lite ./LuiseStoreLite/Resources/luisestorehelper
	@$(MAKE) -C ./LuiseStoreLite package FINALPACKAGE=1
	@$(MAKE) -C ./RootHelper LUISESTORE_LITE=1 clean
	@$(MAKE) -C ./LuiseStoreLite clean
	@$(MAKE) -C ./RootHelper DEBUG=0 LUISESTORE_LITE=1 THEOS_PACKAGE_SCHEME=rootless
	@rm -rf ./LuiseStoreLite/Resources/luisestorehelper
	@cp ./RootHelper/.theos/obj/luisestorehelper_lite ./LuiseStoreLite/Resources/luisestorehelper
	@$(MAKE) -C ./LuiseStoreLite package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless

ci_make_luisestore_lite:
	@$(MAKE) -C ./RootHelper DEBUG=0 LUISESTORE_LITE=1 all
	@rm -rf ./LuiseStoreLite/Resources/luisestorehelper
	@cp ./RootHelper/.theos/obj/luisestorehelper_lite ./LuiseStoreLite/Resources/luisestorehelper
	@$(MAKE) -C ./LuiseStoreLite package FINALPACKAGE=1 all
	@$(MAKE) -C ./RootHelper LUISESTORE_LITE=1 clean
	@$(MAKE) -C ./LuiseStoreLite clean
	@$(MAKE) -C ./RootHelper DEBUG=0 LUISESTORE_LITE=1 THEOS_PACKAGE_SCHEME=rootless all
	@rm -rf ./LuiseStoreLite/Resources/luisestorehelper
	@cp ./RootHelper/.theos/obj/luisestorehelper_lite ./LuiseStoreLite/Resources/luisestorehelper
	@$(MAKE) -C ./LuiseStoreLite package FINALPACKAGE=1 THEOS_PACKAGE_SCHEME=rootless all

else
make_luisestore_lite:
	@$(MAKE) -C ./LuiseStoreLite $(MAKECMDGOALS)
endif

.PHONY: $(TOPTARGETS) ci-build pre_build assemble_luisestore make_trollhelper_package make_trollhelper_embedded build_installer15 build_installer64e