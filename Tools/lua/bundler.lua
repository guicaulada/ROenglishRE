local visited = {}

local function normalize_path(path)
  -- Convert path to use forward slashes and remove any ".lua" extension
  path = path:gsub("\\", "/"):gsub("%.lua$", "")
  -- Handle relative paths
  if path:sub(1, 2) == "./" then
    path = path:sub(3)
  end
  return path
end

local function resolve_path(current_dir, path)
  if path:sub(1, 1) == "/" then
    return path
  end
  return current_dir .. "/" .. path
end

local function get_directory(path)
  return path:match("(.+)/[^/]*$") or ""
end

local function read_file(file_path)
  local full_path = file_path .. ".lua"
  local file = io.open(full_path, "rb") -- Open in binary mode
  if not file then
    print("Warning: Could not open file: " .. full_path)
    return nil
  end
  local content = file:read("*a")
  file:close()
  return content
end

local function process_file(file_path, variables)
  if visited[file_path] then return "" end
  visited[file_path] = true

  local content = read_file(file_path)
  if not content then return "" end

  local current_dir = get_directory(file_path)
  local output = {}

  -- Add file header comment
  table.insert(output, "\n-- Begin: " .. file_path .. ".lua\n")

  -- Split content into lines while preserving exact bytes
  local pos = 1
  local len = #content
  while pos <= len do
    local next_pos = content:find("[\r\n]", pos) or (len + 1)
    local line = content:sub(pos, next_pos - 1)
    local is_processed = false

    -- Handle direct path requires/dofiles
    local path = line:match("require%s*%(?[\"']([^\"']+)[\"']%)?") or
        line:match("dofile%s*%(?[\"']([^\"']+)[\"']%)?")

    if path then
      local normalized_path = normalize_path(path)
      local resolved_path = resolve_path(current_dir, normalized_path)
      table.insert(output, "-- [Bundled] " .. line)
      table.insert(output, process_file(resolved_path, variables))
      is_processed = true
    else
      -- Handle dynamic dofile with variables
      local var_name = line:match("dofile%s*%(?([^%)\"']+)%)?")
      if var_name and variables and variables[var_name:match("[^%s]+")] then
        -- For loops with dofile
        if line:match("^%s*for") then
          table.insert(output, "-- [Bundled Loop Start] " .. line)
          -- Process each file in the loop
          for _, file in ipairs(variables[var_name:match("[^%s]+")]) do
            local normalized_path = normalize_path(file)
            local resolved_path = resolve_path(current_dir, normalized_path)
            table.insert(output, process_file(resolved_path, variables))
          end
          table.insert(output, "-- [Bundled Loop End]")
          is_processed = true
        end
      end
    end

    if not is_processed then
      table.insert(output, line)
    end

    -- Handle line endings
    if content:sub(next_pos, next_pos) == "\r" and content:sub(next_pos + 1, next_pos + 1) == "\n" then
      table.insert(output, "\r\n")
      pos = next_pos + 2
    elseif content:sub(next_pos, next_pos) == "\n" or content:sub(next_pos, next_pos) == "\r" then
      table.insert(output, content:sub(next_pos, next_pos))
      pos = next_pos + 1
    else
      pos = next_pos + 1
    end
  end

  table.insert(output, "\n-- End: " .. file_path .. ".lua\n")
  return table.concat(output, "")
end

-- Get the input file path from command line
local input_file = arg[1]
if not input_file then
  print("Usage: lua bundler.lua <input_file>")
  os.exit(1)
end

local bundled_content = process_file(normalize_path(input_file))

-- Write the bundled output in binary mode
local output_file = io.open(input_file .. ".bundle.lua", "wb")
if output_file then
  output_file:write(bundled_content)
  output_file:close()
  print("Successfully created bundle: " .. input_file .. ".bundle.lua")
else
  print("Error: Could not create output file")
end
