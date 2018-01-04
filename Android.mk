LOCAL_PATH:= $(call my-dir)


# Set odmcheck_density to the density bucket of the device.
odmcheck_density := unknown
ifneq (,$(TARGET_RECOVERY_DENSITY))
    odmcheck_density := $(filter %dpi,$(TARGET_RECOVERY_DENSITY))
else
    ifneq (,$(PRODUCT_AAPT_PREF_CONFIG))
        # If PRODUCT_AAPT_PREF_CONFIG includes a dpi bucket, then use that value.
        odmcheck_density := $(filter %dpi,$(PRODUCT_AAPT_PREF_CONFIG))
    else
        # Otherwise, use the default medium density.
        odmcheck_density := mdpi
    endif
endif

include $(CLEAR_VARS)
LOCAL_MODULE := font.png
LOCAL_SRC_FILES := fonts/$(odmcheck_density)/font.png
LOCAL_MODULE_TAGS := optional
LOCAL_MODULE_CLASS := ETC
LOCAL_MODULE_PATH := $(TARGET_ROOT_OUT)/res/images
include $(BUILD_PREBUILT)


include $(CLEAR_VARS)

define _add-odmcheck-image
    include $$(CLEAR_VARS)
    LOCAL_MODULE := vendor_sony-oss_odmcheck_$(notdir $(1))
    LOCAL_MODULE_STEM := $(notdir $(1))
    _img_modules += $$(LOCAL_MODULE)
    LOCAL_SRC_FILES := $1
    LOCAL_MODULE_TAGS := optional
    LOCAL_MODULE_CLASS := ETC
    LOCAL_MODULE_PATH := $$(TARGET_ROOT_OUT)/res/images
    include $$(BUILD_PREBUILT)
endef

_img_modules :=
_images :=
$(foreach _img, $(call find-subdir-subdir-files, "images/$(odmcheck_density)", "*.png"), \
  $(eval $(call _add-odmcheck-image,$(_img))))

include $(CLEAR_VARS)
LOCAL_MODULE := odmcheck_res_images
LOCAL_MODULE_TAGS := optional
LOCAL_REQUIRED_MODULES := $(_img_modules)
LOCAL_OVERRIDES_PACKAGES := odmcheck_res_images
include $(BUILD_PHONY_PACKAGE)

_add-odmcheck-image :=
_img_modules :=



include $(CLEAR_VARS)

LOCAL_C_INCLUDES := \
    bootable/recovery \
    $(LOCAL_PATH)/include

#LOCAL_C_INCLUDES := bootable/recovery/minui/include $(LOCAL_PATH)/include

LOCAL_SRC_FILES := \
    odmcheck.cpp

LOCAL_SHARED_LIBRARIES := \
    liblog \
    libcutils \
    libpng

LOCAL_STATIC_LIBRARIES := \
    libminui

LOCAL_MODULE := odmcheck
ifeq (1,$(filter 1,$(shell echo "$$(( $(PLATFORM_SDK_VERSION) >= 25 ))" )))
    LOCAL_MODULE_OWNER := sony
    LOCAL_PROPRIETARY_MODULE := true
endif
#LOCAL_MODULE_TAGS := optional

include $(BUILD_EXECUTABLE)

