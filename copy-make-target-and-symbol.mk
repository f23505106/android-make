LOCAL_PATH := $(call my-dir)
include $(CLEAR_VARS)

LOCAL_MODULE    := hello-jni
LOCAL_SRC_FILES := main.cpp 
LOCAL_LDLIBS 	+=  -llog
include $(BUILD_SHARED_LIBRARY)


#复制编译好的so和带symbol的so到指定的目录
#输入1： $(LOCAL_BUILT_MODULE) 指明当前要复制的so的名字，比如libhello-jni.so 
#输入2： $(LOCAL_PATH) 所有相对路径的参照路径 
#输入3： $(APP_ABI) 编译时所有支持的abi
#-----------------------------------
#被复制对象的路径：
#  |-jni
#  |-libs
#      |-armeabi
#         |-libhello-jni.so 
#      |-x86
#         |-libhello-jni.so 
#  |-obj
#      |-local
#         |-armeabi
#             |-libhello-jni.so 
#         |-x86
#             |-libhello-jni.so 
#-----------------------------------
#复制后的对象路径：
# $(COPY_TO_PATH)
#  |-symbol
#      |-libs
#         |-armeabi
#             |-libhello-jni.so 
#         |-x86
#             |-libhello-jni.so 
#  |-release
#      |-libs
#         |-armeabi
#             |-libhello-jni.so 
#         |-x86
#             |-libhello-jni.so 
############################################
COPY_TO_PATH := $(LOCAL_PATH)/../my_so
TARGETS_NAME := $(notdir $(LOCAL_BUILT_MODULE))

SYMBOL_COPY_TO_PATH := $(COPY_TO_PATH)/symbol/libs
RELEASE_COPY_TO_PATH := $(COPY_TO_PATH)/release/libs

SYMBOL_TO_TARGETS := $(foreach abi,$(APP_ABI),$(SYMBOL_COPY_TO_PATH)/$(abi)/$(TARGETS_NAME))
SYMBOL_FROM_TARGETS := $(foreach abi,$(APP_ABI),obj/local/$(abi)/$(TARGETS_NAME))
RELEASE_TO_TARGETS := $(foreach abi,$(APP_ABI),$(RELEASE_COPY_TO_PATH)/$(abi)/$(TARGETS_NAME))
RELEASE_FROM_TARGETS := $(foreach abi,$(APP_ABI),libs/$(abi)/$(TARGETS_NAME))

all:$(SYMBOL_TO_TARGETS) $(RELEASE_TO_TARGETS)

# 
$(SYMBOL_TO_TARGETS):$(SYMBOL_FROM_TARGETS)
	@mkdir -p $(dir $@)
	cp $(subst $(SYMBOL_COPY_TO_PATH),obj/local,$@)  $@
$(RELEASE_TO_TARGETS):$(RELEASE_FROM_TARGETS)
	@mkdir -p $(dir $@)
	cp $(subst $(RELEASE_COPY_TO_PATH),libs,$@)  $@
