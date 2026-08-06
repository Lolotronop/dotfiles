local mp = require("mp")
local utils = require("mp.utils")

local subtitle_extensions = {
    srt = true,
    ass = true,
    ssa = true,
    sub = true,
    vtt = true,
    sup = true,
}

local audio_extensions = {
    aac = true,
    ac3 = true,
    dts = true,
    eac3 = true,
    flac = true,
    m4a = true,
    mp3 = true,
    mka = true,
    ogg = true,
    opus = true,
    wav = true,
}

-- Prevent unrelated files such as "S01" and "S02" from matching.
local minimum_prefix_length = 3

local function dirname(path)
    return path:match("^(.*)[/\\][^/\\]+$") or "."
end

local function basename(path)
    return path:match("([^/\\]+)$") or path
end

local function remove_extension(name)
    return name:gsub("%.[^%.]+$", "")
end

local function extension(name)
    return (name:match("%.([^%.]+)$") or ""):lower()
end

local function longest_common_prefix(a, b)
    local limit = math.min(#a, #b)
    local length = 0

    -- Case-insensitive matching.
    a = a:lower()
    b = b:lower()

    for i = 1, limit do
        if a:sub(i, i) ~= b:sub(i, i) then
            break
        end

        length = i
    end

    return length
end

local function recursively_collect(directory, output)
    local entries = utils.readdir(directory, "all")

    if not entries then
        return
    end

    for _, entry in ipairs(entries) do
        -- Avoid pseudo-directory entries where present.
        if entry ~= "." and entry ~= ".." then
            local path = utils.join_path(directory, entry)
            local info = utils.file_info(path)

            if info then
                if info.is_dir then
                    recursively_collect(path, output)
                elseif info.is_file then
                    table.insert(output, path)
                end
            end
        end
    end
end

local function add_best_candidates(candidates, command)
    if #candidates == 0 then
        return
    end

    local best_score = 0

    for _, candidate in ipairs(candidates) do
        if candidate.score > best_score then
            best_score = candidate.score
        end
    end

    local best_candidates = {}

    for _, candidate in ipairs(candidates) do
        if candidate.score == best_score then
            table.insert(best_candidates, candidate)
        end
    end

    table.sort(best_candidates, function(a, b)
        return a.path < b.path
    end)

    for index, candidate in ipairs(best_candidates) do
        local mode = index == 1 and "select" or "auto"
        mp.commandv(command, candidate.path, mode)

        mp.msg.info(string.format(
            "Added %s: %s (%d matching characters)",
            command,
            candidate.path,
            candidate.score
        ))
    end
end
local function load_matching_tracks()
    local media_path = mp.get_property_native("path")

    -- Ignore URLs, pipes and other non-local inputs.
    if not media_path or media_path:find("://", 1, true) then
        return
    end

    local working_directory = mp.get_property_native("working-directory") or "."
    local absolute_path = utils.join_path(working_directory, media_path)
    local current_directory = dirname(absolute_path)

    -- "Adjacent directories" are interpreted as everything beneath the
    -- current directory's parent:
    --
    --   Show/
    --     Video/
    --     Subtitles/
    --     Audio/
    --
    -- Opening Show/Video/Episode.mkv scans all of Show/ recursively.
    -- local scan_root = dirname(current_directory) -- for the version above
    local scan_root = current_directory -- for the curr dir and down

    local media_name = remove_extension(basename(absolute_path))
    local files = {}

    recursively_collect(scan_root, files)

    local subtitles = {}
    local audio = {}

    for _, path in ipairs(files) do
        if path ~= absolute_path then
            local candidate_name = remove_extension(basename(path))
            local score = longest_common_prefix(media_name, candidate_name)
            local ext = extension(path)

            if score >= minimum_prefix_length then
                local candidate = {
                    path = path,
                    score = score,
                }

                if subtitle_extensions[ext] then
                    table.insert(subtitles, candidate)
                elseif audio_extensions[ext] then
                    table.insert(audio, candidate)
                end
            end
        end
    end

    add_best_candidates(subtitles, "sub-add")
    add_best_candidates(audio, "audio-add")
end

mp.register_event("file-loaded", load_matching_tracks)