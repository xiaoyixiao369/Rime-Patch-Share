-- Rime Lua 扩展 https://github.com/hchunhui/librime-lua
-- 文档 https://github.com/hchunhui/librime-lua/wiki/Scripting

-- processors:

-- 以词定字，可在 default.yaml → key_binder 下配置快捷键，默认为左右中括号 [ ]
select_character = require("select_character")

-- translators:

-- 日期时间，可在方案中配置触发关键字。
date_translator = require("date_translator")

-- 农历，可在方案中配置触发关键字。
lunar = require("lunar")

-- Unicode，U 开头
unicode = require("unicode")

-- 数字、人民币大写，R 开头
number_translator = require("number_translator")

-- filters:

-- 错音错字提示
-- 关闭此 Lua 时，同时需要关闭 translator/spelling_hints，否则 comment 里都是拼音
corrector = require("corrector")

-- v 模式 symbols 优先（全拼）
v_filter = require("v_filter")

-- 自动大写英文词汇
autocap_filter = require("autocap_filter")

-- 降低部分英语单词在候选项的位置，可在方案中配置要降低的模式和单词
reduce_english_filter = require("reduce_english_filter")

-- 辅码，https://github.com/mirtlecn/rime-radical-pinyin/blob/master/search.lua.md
search = require("search")

-- 置顶候选项
pin_cand_filter = require("pin_cand_filter")

-- 长词优先（全拼）
long_word_filter = require("long_word_filter")

-- 默认未启用：

-- 中英混输词条自动空格
-- 在 engine/filters 增加 - lua_filter@cn_en_spacer
cn_en_spacer = require("cn_en_spacer")

-- 英文词条上屏自动空格
-- 在 engine/filters 增加 - lua_filter@en_spacer
en_spacer = require("en_spacer")

-- 九宫格，将输入框的数字转为对应的拼音或英文，iRime 用，Hamster 不需要。
-- 在 engine/filters 增加 - lua_filter@t9_preedit
t9_preedit = require("t9_preedit")

-- 根据是否在用户词典，在 comment 上加上一个星号 *
-- 在 engine/filters 增加 - lua_filter@is_in_user_dict
-- 在方案里写配置项：
-- is_in_user_dict: true     为输入过的内容加星号
-- is_in_user_dict: false    为未输入过的内容加星号
is_in_user_dict = require("is_in_user_dict")

-- 词条隐藏、降频
-- 在 engine/processors 增加 - lua_processor@cold_word_drop_processor
-- 在 engine/filters 增加 - lua_filter@cold_word_drop_filter
-- 在 key_binder 增加快捷键：
-- turn_down_cand: "Control+j"  # 匹配当前输入码后隐藏指定的候选字词 或候选词条放到第四候选位置
-- drop_cand: "Control+d"       # 强制删词, 无视输入的编码
-- get_record_filername() 函数中仅支持了 Windows、macOS、Linux
cold_word_drop_processor = require("cold_word_drop.processor")
cold_word_drop_filter = require("cold_word_drop.filter")


-- 暴力 GC
-- 详情 https://github.com/hchunhui/librime-lua/issues/307
-- 这样也不会导致卡顿，那就每次都调用一下吧，内存稳稳的
function force_gc()
    -- collectgarbage()
    collectgarbage("step")
end

-- 临时用的
function debug_checker(input, env)
    for cand in input:iter() do
        yield(ShadowCandidate(
            cand,
            cand.type,
            cand.text,
            env.engine.context.input .. " - " .. env.engine.context:get_preedit().text .. " - " .. cand.preedit
        ))
    end
end


--- 以下是我新增的配置 ---

------------------------------------------------

-- 获取输入法常用参数
-- env.engine.context:get_commit_text() -- filter中为获取编码
-- env.engine.context:get_script_text()-- 获取编码带引导符
-- local caret_pos = env.engine.context.caret_pos          - 光标的位置通常可以理解为单字节编码长度
-- local schema = env.engine.schema.config:get_int('menu/page_size')         -- 获取方案候选项数目参数
-- local ascii_mode=env.engine.context:get_option("ascii_mode")  -- env.engine.context:set_option("ascii_mode", not ascii_mode)
-- local schema_id=env.engine.schema.schema_id         -- 获取方案id
-- local schema_name=env.engine.schema.schema_name         -- 获取方案名称
-- local sync_dir=rime_api.get_sync_dir()         -- 获取同步资料目录
-- local rime_version=rime_api.get_rime_version()         -- 获取rime版本号--macos无效
-- local shared_data_dir=rime_api.get_shared_data_dir()         -- 获取程序目录data路径
-- local user_data_dir=rime_api.get_user_data_dir()         -- 获取用户目录路

------------------------------------------------

--- 计算器插件, 使用=触发
calculator_translator = require("calculator_translator")
--  导入log模块记录日志
--local logEnable, log = pcall(require, "runLog")
-- 复制文件函数
local function copy_file_by_lua(sourceFilePath, destinationFilePath) 
    -- 打开源文件
    local sourceFile = assert(io.open(sourceFilePath, "rb"))
    if not sourceFile then
        log.writeLog("无法打开源文件: " .. sourceFile)
        return
    end

    -- 创建或覆盖目标文件
    local destinationFile = assert(io.open(destinationFilePath, "wb"))
    if not destinationFile then
        log.writeLog("无法创建目标文件: " .. destinationFilePath)
        sourceFile:close()
        return
    end

    -- 读取源文件内容并写入目标文件
    local chunkSize = 4096 -- 可以调整缓冲区大小以适应不同需求
    local chunk = sourceFile:read(chunkSize)
    while chunk do
        destinationFile:write(chunk)
        chunk = sourceFile:read(chunkSize)
    end

    -- 清理：关闭文件
    sourceFile:close()
    destinationFile:close()

end

-- 获取当前文件所在目录
local function get_current_file_dir() 
    return string.sub(debug.getinfo(1).source, 2, string.len("/rime.lua") * -1)
end

-- 获取小狼毫程序安装目录中data目录路径
local shared_data_dir = rime_api.get_shared_data_dir()
-- 计算小狼毫的程序安装路径，并将路径中的\替换成/，以兼容Linux
local weasel_install_path = string.gsub(shared_data_dir, '\\', '/'):gsub("/data$", "")
--log.writeLog('weasel_install_path:'..weasel_install_path)

-- 获取用户文件路径，并将路径中的\替换成/，以兼容Linux
local weasel_user_path=string.gsub(rime_api.get_user_data_dir(), '\\', '/')
--log.writeLog('weasel_user_path:'..weasel_user_path)
-- 拷贝simplehttp.dll文件到安装目录
copy_file_by_lua(weasel_user_path..'/simplehttp/simplehttp.dll', weasel_install_path..'/simplehttp.dll')      

-- 拷贝拼音音音调文件
copy_file_by_lua(weasel_user_path..'/pinyin_tone/zdict.reverse.bin', weasel_user_path..'/build/zdict.reverse.bin')
copy_file_by_lua(weasel_user_path..'/pinyin_tone/kMandarin.reverse.bin', weasel_user_path..'/build/kMandarin.reverse.bin')
copy_file_by_lua(weasel_user_path..'/pinyin_tone/pinyin.reverse.bin', weasel_user_path..'/build/pinyin.reverse.bin')
copy_file_by_lua(weasel_user_path..'/pinyin_tone/tone.reverse.bin', weasel_user_path..'/build/tone.reverse.bin')


--- 自动替换updateRepoAndSync.bat中的小狼毫程序安装目录、用户目录
-- updateRepoAndSync.bat文件路径
local updateRepoAndSyncBatTemplatePath = weasel_user_path..'/updateRepoAndSync.template.bat'
local updateRepoAndSyncBatPath = weasel_user_path..'/updateRepoAndSync.bat'
-- 读取文件内容
local updateRepoAndSyncBatTemplatePathData = ""
local templateFile = io.open(updateRepoAndSyncBatTemplatePath, "r")
if templateFile then
    updateRepoAndSyncBatTemplatePathData = templateFile:read("*a") -- 读取整个文件
    templateFile:close()
else
    print("无法打开文件:", templateFile)
    return
end

-- 使用gsub函数替换内容
local updateRepoAndSyncBatPathData = string.gsub(updateRepoAndSyncBatTemplatePathData, "{user_path}", weasel_user_path)
updateRepoAndSyncBatPathData = string.gsub(updateRepoAndSyncBatPathData, "{install_path}", weasel_install_path)
-- 将替换后的内容写入新文件
local updateRepoAndSyncBatPathFile = io.open(updateRepoAndSyncBatPath, "w")
if updateRepoAndSyncBatPathFile then
    updateRepoAndSyncBatPathFile:write(updateRepoAndSyncBatPathData)
    updateRepoAndSyncBatPathFile:close()
    print("替换内容已写入新文件:", updateRepoAndSyncBatPath)
else
    print("无法写入新文件:", updateRepoAndSyncBatPath)
end



--- 百度云拼音插件，Control+8 为云输入触发键。注意：这个配置一定要放到最后，放到最后，放到最后。
--  使用方法：
--  将 "lua_translator@baidu_translator" 和 "lua_processor@baidu_processor"
--  分别加到输入方案的 engine/translators 和 engine/processors 中
local baidu = require("trigger")("Control+8", require("baidu"))
baidu_translator = baidu.translator
baidu_processor = baidu.processor