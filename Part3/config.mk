# 設計名稱與平台
export DESIGN_NAME = FinalCPU
export PLATFORM    = nangate45
export SYNTH_HIERARCHICAL = 1

# RTL_MP Settings
export RTLMP_MAX_INST = 30000
export RTLMP_MIN_INST = 5000
export RTLMP_MAX_MACRO = 16
export RTLMP_MIN_MACRO = 4
export RTLMP_SIGNATURE_NET_THRESHOLD = 30

# 設計檔案路徑
export VERILOG_FILES = $(wildcard $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/*.v)
export SDC_FILE      = $(DESIGN_HOME)/$(PLATFORM)/$(DESIGN_NAME)/constraint.sdc

export ADDITIONAL_LEFS = $(PLATFORM_DIR)/lef/fakeram45_256x16.lef
export ADDITIONAL_LIBS = $(PLATFORM_DIR)/lib/fakeram45_256x16.lib

export DIE_AREA    = 0 0 400 400
export CORE_AREA   = 20 20 380 380

export MACRO_PLACE_HALO = 10 10
export MACRO_PLACE_CHANNEL = 20 20
export TNS_END_PERCENT = 100
export PLACE_DENSITY = 0.30

