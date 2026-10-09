--[[
   Configuration script for l3build from the spintent package.
   At the moment the possible targets that can be passed are:
   * tag        : Update the version and date
   * doc        : Generate the documentation [-q]
   * unpack     : Unpacks the source files [-q]
   * install    : Install the package locally, you can use
                  it in conjunction with [--full] [--dry-run]
   * uninstall  : Uninstall the package locally
   * clean      : Clean the directory tree and repo
   * ctan       : Generate the compressed package (.zip)
   * upload     : Upload the package to ctan, you must add
                  -F ctan.ann in conjunction with [--debug]
   * tagcheck   : Check version and date in files
   * testpkg    : Compile all example files included in /test-pkg
   * examples   : Compile all example files included in .dtx file
   * release    : It performs the checks before generating a public
                  release (on git and ctan).
--]]

-- General package identification
module     = "spintent"
pkgversion = "0.99"
pkgdate    = "2026-10-07"
ltxrelease = "2026-11-01"

-- Configuration of files for build and installation
maindir       = "."
sourcefiledir = "./sources"
textfiledir   = "./sources"
sourcefiles   = {"**/*.dtx", "**/*.ins"}
installfiles  = {"**/*.sty", "**/*.lua"}
tdslocations  = {
  "tex/lualatex/spintent/spintent.sty",
  "tex/lualatex/spintent/spintent.lua",
  "doc/lualatex/spintent/spintent.pdf",
  "doc/lualatex/spintent/README.md",
  "scripts/spitool/spitool.lua",
  "source/lualatex/spintent/spintent.dtx",
  "source/lualatex/spintent/spintent.ins",
}

-- Unpacking files from spintent.ins
unpackfiles = { "spintent.ins" }
unpackopts  = "--interaction=batchmode"
unpackexe   = "luatex"

-- Regression tests (l3build check / save): the .lvt files in ./testfiles.
-- ltxrelease needs the development format, so the tests run with latex-dev.
testfiledir  = "./testfiles"
checkengines = { "luatex" }
stdengine    = "luatex"
checkformat  = "latex-dev"

-- The mathml-SE structure elements carry sequential ids (ID.00012, ...): one
-- node more or less would shift all the following ones and flood the diff,
-- so the ids are not compared.
function normalize_log_hook(line)
  return (string.gsub(line, 'id="ID%.%d+"', 'id="ID.NN"'))
end

-- Typesetting spintent documentation step by step :)

function docinit_hook()
  local errorlevel = (cp("*mylhmc.lua", sourcefiledir, typesetdir) + cp("*mylhmc.sty", sourcefiledir, typesetdir))
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy mylhmc.lua and mylhmc.lua files from "..sourcefiledir.." to "..typesetdir)
    return errorlevel
  end
  return 0
end

function typeset(file)
  print("** Running: arara "..file..".dtx")
  local file = jobname(sourcefiledir.."/spintent.dtx")
  local errorlevel = runcmd("arara "..file..".dtx", typesetdir, {"TEXINPUTS","LUAINPUTS"})
  if errorlevel ~= 0 then
    error("Error!!: Typesetting "..file..".dtx")
    return errorlevel
  end
  return 0
end

-- Configuration for ctan
ctanreadme = "CTANREADME.md"
ctanpkg    = "spintent"
ctanzip    = ctanpkg.."-"..pkgversion
packtdszip = false

--  Configuration for package distribution in ctan
uploadconfig = {
  author       = "Pablo González L",
  uploader     = "Pablo González L",
  email        = "pablgonz@yahoo.com",
  pkg          = ctanpkg,
  version      = pkgversion,
  license      = "lppl1.3c",
  summary      = "Spanish parse intents",
  description  =[[The ⟨spintent⟩ package provides a series of utilities for primary and secondary
  school teachers who need to create accessible PDF documents (tagged PDF) in Spanish using LuaLaTeX.]],
  topic        = { "spanish", "macros", "list", "tagged-pdf" },
  ctanPath     = "/macros/latex/contrib/" .. ctanpkg,
  repository   = "https://github.com/pablgonz/" .. module,
  bugtracker   = "https://github.com/pablgonz/" .. module .. "/issues",
  support      = "https://github.com/pablgonz/" .. module .. "/issues",
  note         = [[Uploaded automatically by l3build...]],
  announcement_file="ctan.ann",
  update       = true
}

-- Clean files
cleanfiles = {module..".pdf", ctanzip..".curlopt", ctanzip..".zip"}

-- Update package date and version
tagfiles = {
  "sources/spintent.dtx",
  "sources/spintent.sty",
  "sources/spintent.lua",
  "sources/CTANREADME.md",
  "ctan.ann"
}

-- Line length helper (80 chars layout)
local function os_message(text)
  local mymax = 77 - string.len(text) - string.len("done")
  if mymax < 1 then mymax = 1 end
  print(text .. " " .. string.rep(".", mymax) .. " done")
end

-- Helper para detectar si un ejecutable existe en el PATH (Windows y Linux)
local function has_cmd(cmd)
  local is_windows = package.config:sub(1, 1) == "\\"
  local null_dev = os_null or (is_windows and "NUL" or "/dev/null")
  local check = is_windows and ("where " .. cmd .. " > " .. null_dev .. " 2>&1")
                           or ("command -v " .. cmd .. " > " .. null_dev .. " 2>&1")
  local res = os.execute(check)
  return (res == true or res == 0)
end

-- Helper to safely read file content
local function read_file(filepath)
  local f = io.open(filepath, "r")
  if not f then return nil end
  local content = f:read("*all")
  f:close()
  return content
end

-- Update function with smart check (avoids redundant rewrites) --
-- revisa PRIMERO si el archivo ya tiene el tag/fecha correctos antes
-- de tocar el contenido; si coincide, no ejecuta ningun gsub.
function update_tag(file, content, tagname, tagdate)
  tagname = pkgversion
  tagdate = pkgdate

  -- ¿Este archivo ya esta al dia?
  local already_ok = nil

  if string.match(file, "spintent%.dtx$") then
    local fver = string.match(content, "\\def\\fileversion{%s*v?(.-)%s*}")
    local fdate = string.match(content, "\\def\\filedate{%s*(.-)%s*}")
    local pkgd, pkgv = string.match(content, "\\ProvidesExplPackage%s*{spintent}%s*{(.-)}%s*{(.-)}")
    local ltxr = string.match(content, "\\NeedsTeXFormat%s*{LaTeX2e}%s*%[(%d%d%d%d%-%d%d%-%d%d)%]")
    local luav, luad = string.match(content, "%-%s*v(%d+%.%d+%a*)%s*%[(%d%d%d%d%-%d%d%-%d%d)%]")
    already_ok = (fver == tagname and fdate == tagdate and pkgv == tagname
      and pkgd == tagdate and ltxr == ltxrelease and luav == tagname and luad == tagdate)

  elseif string.match(file, "spintent%.sty$") then
    local pkgd, pkgv = string.match(content, "\\ProvidesExplPackage%s*{spintent}%s*{(.-)}%s*{(.-)}")
    local ltxr = string.match(content, "\\NeedsTeXFormat%s*{LaTeX2e}%s*%[(%d%d%d%d%-%d%d%-%d%d)%]")
    already_ok = (pkgv == tagname and pkgd == tagdate and ltxr == ltxrelease)

  elseif string.match(file, "spintent%.lua$") then
    local luav, luad = string.match(content, "%-%s*v(%d+%.%d+%a*)%s*%[(%d%d%d%d%-%d%d%-%d%d)%]")
    already_ok = (luav == tagname and luad == tagdate)

  elseif string.match(file, "CTANREADME%.md$") then
    local m_readmev, m_readmed = string.match(content, "Release%s+(v%d+%.%d+%a*)%s+\\%[(%d%d%d%d%-%d%d%-%d%d)\\%]")
    already_ok = (m_readmev == "v" .. tagname and m_readmed == tagdate)

  elseif string.match(file, "ctan%.ann$") then
    local annv = string.match(content, "v%d+%.%d+%a*")
    already_ok = (annv == "v" .. tagname)
  end

  if already_ok then
    print("** " .. file .. " is already up to date")
    return content
  end

  local original_content = content

  -- Substitutions in spintent.dtx
  if string.match(file, "spintent%.dtx$") then
    content = string.gsub(content, "\\def\\fileversion{%s*v?.-%s*}", "\\def\\fileversion{v" .. tagname .. "}")
    content = string.gsub(content, "\\def\\filedate{%s*.-%s*}", "\\def\\filedate{" .. tagdate .. "}")
    content = string.gsub(content, "(\\ProvidesExplPackage%s*{spintent}%s*){[^}]+}%s*{[^}]+}", "%1{" .. tagdate .. "} {" .. tagname .. "}")
    content = string.gsub(content, "(\\NeedsTeXFormat{LaTeX2e})%[%d%d%d%d%-%d%d%-%d%d%]", "%1[" .. ltxrelease .. "]")
    content = string.gsub(content, "(%-%s*v)%d+%.%d+%a*%s*%[%d%d%d%d%-%d%d%-%d%d%]", "%1" .. tagname .. " [" .. tagdate .. "]")
  end

  -- Substitutions in spintent.sty
  if string.match(file, "spintent%.sty$") then
    content = string.gsub(content, "(\\ProvidesExplPackage%s*{spintent}%s*){[^}]+}%s*{[^}]+}", "%1{" .. tagdate .. "} {" .. tagname .. "}")
    content = string.gsub(content, "(\\NeedsTeXFormat{LaTeX2e})%[%d%d%d%d%-%d%d%-%d%d%]", "%1[" .. ltxrelease .. "]")
  end

  -- Substitutions in spintent.lua
  if string.match(file, "spintent%.lua$") then
    content = string.gsub(content, "(%-%s*v)%d+%.%d+%a*%s*%[%d%d%d%d%-%d%d%-%d%d%]", "%1" .. tagname .. " [" .. tagdate .. "]")
  end

  -- Substitutions in CTANREADME.md
  if string.match(file, "CTANREADME%.md$") then
    content = string.gsub(content, "Release v%d+%.%d+%a*%s*\\%[%d%d%d%d%-%d%d%-%d%d\\%]", "Release v" .. tagname .. " \\[" .. tagdate .. "\\]")
  end

  -- Substitutions in ctan.ann
  if string.match(file, "ctan%.ann$") then
    content = string.gsub(content, "v%d+%.%d+%a*", "v" .. tagname)
  end

  print("** " .. file .. " has been tagged with version " .. tagname .. " and date " .. tagdate)

  return content
end

-- Individual verification functions
local function check_dtx_tags()
  local content = read_file("sources/spintent.dtx")
  if not content then return false end

  local fver = string.match(content, "\\def\\fileversion{%s*v?(.-)%s*}")
  local fdate = string.match(content, "\\def\\filedate{%s*(.-)%s*}")
  local pkgd, pkgv = string.match(content, "\\ProvidesExplPackage%s*{spintent}%s*{(.-)}%s*{(.-)}")
  local ltxr = string.match(content, "\\NeedsTeXFormat%s*{LaTeX2e}%s*%[(%d%d%d%d%-%d%d%-%d%d)%]")
  local luav, luad = string.match(content, "%-%s*v(%d+%.%d+%a*)%s*%[(%d%d%d%d%-%d%d%-%d%d)%]")

  if fver ~= pkgversion or fdate ~= pkgdate or pkgv ~= pkgversion or pkgd ~= pkgdate or ltxr ~= ltxrelease or luav ~= pkgversion or luad ~= pkgdate then
    print("** Warning: Mismatches found in sources/spintent.dtx")
    return false
  end
  os_message("Checking version, date, and LaTeX release in spintent.dtx")
  return true
end

local function check_sty_tags()
  local content = read_file("sources/spintent.sty")
  if not content then return true end

  local pkgd, pkgv = string.match(content, "\\ProvidesExplPackage%s*{spintent}%s*{(.-)}%s*{(.-)}")
  local ltxr = string.match(content, "\\NeedsTeXFormat%s*{LaTeX2e}%s*%[(%d%d%d%d%-%d%d%-%d%d)%]")

  if pkgv ~= pkgversion or pkgd ~= pkgdate or ltxr ~= ltxrelease then
    print("** Warning: Mismatches found in sources/spintent.sty")
    return false
  end
  os_message("Checking version, date, and LaTeX release in spintent.sty")
  return true
end

local function check_lua_tags()
  local content = read_file("sources/spintent.lua")
  if not content then return true end

  local luav, luad = string.match(content, "%-%s*v(%d+%.%d+%a*)%s*%[(%d%d%d%d%-%d%d%-%d%d)%]")

  if luav ~= pkgversion or luad ~= pkgdate then
    print("** Warning: Mismatches found in sources/spintent.lua")
    return false
  end
  os_message("Checking version and date in spintent.lua")
  return true
end

local function check_readme_tags()
  local content = read_file("sources/CTANREADME.md")
  if not content then return false end

  local target_version = "v" .. pkgversion
  local m_readmev, m_readmed = string.match(content, "Release%s+(v%d+%.%d+%a*)%s+\\%[(%d%d%d%d%-%d%d%-%d%d)\\%]")

  if target_version ~= m_readmev or pkgdate ~= m_readmed then
    print("** Warning: Mismatches found in sources/CTANREADME.md")
    return false
  end
  os_message("Checking version and date in README.md")
  return true
end

-- Unified verification runner
local function check_all_tags()
  local ok_dtx = check_dtx_tags()
  local ok_sty = check_sty_tags()
  local ok_lua = check_lua_tags()
  local ok_readme = check_readme_tags()
  return ok_dtx and ok_sty and ok_lua and ok_readme
end

-- Leave tag_hook empty so 'l3build tag' doesn't execute redundant checks after writing
function tag_hook(tagname)
end

-- Standalone audit target: l3build tagcheck
if options["target"] == "tagcheck" then
  if check_all_tags() then
    os.exit(0)
  else
    os.exit(1)
  end
end

-- Helper function to generate an isolated build environment --
local function system_temp_dir()
  local is_windows = package.config:sub(1, 1) == "\\"
  if is_windows then
    return os.getenv("TEMP") or os.getenv("TMP") or "C:\\Windows\\Temp"
  else
    return os.getenv("TMPDIR") or "/tmp"
  end
end

local function make_tmp_dir()
  -- Unified tag verification before unpacking
  if not check_all_tags() then
    error("** Error!!: Tag verification failed before preparing environment")
  end

  local sep = package.config:sub(1, 1)
  local base = system_temp_dir()
  local tmpname = os.tmpname()
  local unique = tmpname:match("([^/\\]+)$") or tostring(os.time())
  os.remove(tmpname) -- os.tmpname() a veces crea el archivo vacio; no hace falta

  tmpdir = base .. sep .. "spintent-build-" .. unique -- Global variable consumed by custom targets

  -- Create temporary directory
  local errorlevel = mkdir(tmpdir)
  if errorlevel ~= 0 then
    error("** Error!!: Could not create temporary directory " .. tmpdir)
  else
    os_message("Creating temporary directory " .. tmpdir)
  end

  -- Copy source files (.dtx and .ins)
  errorlevel = cp("*.dtx", sourcefiledir, tmpdir) + cp("*.ins", sourcefiledir, tmpdir)
  if errorlevel ~= 0 then
    error("** Error!!: Failed to copy source files to " .. tmpdir)
  else
    os_message("Copying spintent.dtx and spintent.ins to " .. tmpdir)
  end

  -- Unpack source files
  os_message("Unpacking source files in " .. tmpdir)
  local file = jobname("spintent.ins")
  errorlevel = run(tmpdir, "luatex -interaction=batchmode " .. file .. ".ins > " .. os_null)
  if errorlevel ~= 0 then
    local f = io.open(tmpdir .. "/" .. file .. ".log", "r")
    if f then
      print(f:read("*all"))
      f:close()
    end
    cp(file .. ".log", tmpdir, maindir)
    cp(file .. ".ins", tmpdir, maindir)
    error("** Error!!: Unpacking failed with luatex")
  else
    os_message("Successfully unpacked " .. file .. ".ins")
    rm(tmpdir, file .. ".log")
  end
  return 0
end

-- Custom target: l3build testpkg
if options["target"] == "testpkg" then
  make_tmp_dir()

  -- Copiar únicamente archivos .tex
  local errorlevel = cp("*.tex", "tagged-test", tmpdir)
  if errorlevel ~= 0 then
    error("** Error!!: Failed to copy .tex files from ./tagged-test to ./" .. tmpdir)
  else
    os_message("Copied .tex files from ./tagged-test to ./" .. tmpdir)
  end

  local tex_files = {}
  for file in lfs.dir("tagged-test") do
    if file:match("%.tex$") then
      table.insert(tex_files, file)
    end
  end
  table.sort(tex_files)

  if #tex_files == 0 then
    print("** Warning: No .tex files found in ./tagged-test")
  else
    -- Detección de herramientas requeridas
    local run_rnv = has_cmd("rnv-wrapp") and has_cmd("show-pdf-tags")
    local run_verapdf = has_cmd("verapdf")

    if run_rnv and run_verapdf then
      os_message("Validators detected: show-pdf-tags, rnv-wrapp & veraPDF")
    elseif run_rnv then
      os_message("Validators detected: show-pdf-tags & rnv-wrapp")
    elseif run_verapdf then
      os_message("Validator detected: veraPDF")
    end

    os_message("Compiling test files with lualatex-dev")
    for _, sample in ipairs(tex_files) do
      os_message("Compiling " .. sample)
      errorlevel = run(tmpdir, "lualatex-dev -interaction=nonstopmode " .. sample .. " > " .. os_null)
      if errorlevel ~= 0 then
        local log_file = sample:gsub("%.tex$", ".log")
        local f = io.open(tmpdir .. "/" .. log_file, "r")
        if f then
          print(f:read("*all"))
          f:close()
        end
        error("** Error!!: lualatex-dev compilation failed for " .. sample)
      end

      local pdf_file = sample:gsub("%.tex$", ".pdf")

      -- Mensaje unificado según disponibilidad
      if run_rnv and run_verapdf then
        os_message("Validating RNC tags and PDF/UA-2 in " .. pdf_file)
      elseif run_rnv then
        os_message("Validating RNC tags in " .. pdf_file)
      elseif run_verapdf then
        os_message("Validating PDF/UA-2 in " .. pdf_file)
      end

      -- 1. Validación RNC (show-pdf-tags + rnv-wrapp)
      if run_rnv then
        local cmd_rnv = "show-pdf-tags --xml " .. pdf_file .. " | rnv-wrapp"
        errorlevel = run(tmpdir, cmd_rnv .. " > " .. os_null)
        if errorlevel ~= 0 then
          print("\n[RNC Validation Error Output]:")
          run(tmpdir, cmd_rnv) -- Muestra el reporte de error detallado
          error("** Error!!: Tag structure validation (rnv-wrapp) failed for " .. pdf_file)
        end
      end

      -- 2. Validación PDF/UA-2 (veraPDF)
      if run_verapdf then
        local cmd_vera = "verapdf --flavour ua2 --format text " .. pdf_file
        errorlevel = run(tmpdir, cmd_vera .. " > " .. os_null)
        if errorlevel ~= 0 then
          print("\n[PDF/UA-2 Validation Error Output]:")
          run(tmpdir, cmd_vera) -- Muestra el reporte de error detallado
          error("** Error!!: veraPDF (PDF/UA-2) validation failed for " .. pdf_file)
        end
      end

      if run_rnv or run_verapdf then
        print("PASS")
      end
    end
  end

  errorlevel = cp("*.pdf", tmpdir, maindir)
  if errorlevel ~= 0 then
    print("** Notice: No PDF files generated or copied to main directory")
  else
    os_message("Copied generated PDF files to main directory")
  end

  cleandir(tmpdir)
  lfs.rmdir(tmpdir)
  os_message("Removed temporary directory ./" .. tmpdir)
  os.exit(0)
end

-- Custom target: l3build examples
if options["target"] == "examples" then
  make_tmp_dir()

  local file = jobname("spintent.dtx")
  os_message("Extracting examples from " .. file .. ".dtx")

  local errorlevel = run(tmpdir, "lualatex-dev " .. file .. ".dtx > " .. os_null)
  if errorlevel ~= 0 then
    error("** Error!!: Example extraction failed on " .. file .. ".dtx")
  else
    os_message("Extracted examples from " .. file .. ".dtx")
  end

  os_message("Compiling example files with arara")
  local samples = {"spintent-exa-1", "spintent-exa-2", "spintent-exa-3", "spintent-exa-4", "spintent-exa-5", "spintent-exa-6"}
  for _, sample in ipairs(samples) do
    errorlevel = run(tmpdir, "arara " .. sample .. ".tex > " .. os_null)
    if errorlevel ~= 0 then
      local f = io.open(tmpdir .. "/" .. sample .. ".log", "r")
      if f then
        print(f:read("*all"))
        f:close()
      end
      cp(sample .. ".tex", tmpdir, maindir)
      cp(sample .. ".log", tmpdir, maindir)
      error("** Error!!: arara compilation failed for " .. sample .. ".tex")
    else
      os_message("Compiled " .. sample .. ".tex")
    end
  end

  errorlevel = cp("spintent-*.pdf", tmpdir, maindir)
  if errorlevel ~= 0 then
    error("** Error!!: Failed to copy generated PDF files to main directory")
  else
    os_message("Copied generated PDF files to main directory")
  end

  cleandir(tmpdir)
  lfs.rmdir(tmpdir)
  os_message("Removed temporary directory ./" .. tmpdir)
  os.exit(0)
end

-- Clean repo with Git
-- 'git clean -x' removes EVERYTHING untracked (new files not yet added and
-- ignored files too), so it lists what would go and asks before deleting.
-- With --dry-run it only lists.
if options["target"] == "clean" then
  local function git_out(cmd)
    local f = io.popen(cmd .. " 2>&1", "r")
    if not f then return nil end
    local out = f:read("*a") or ""
    f:close()
    return out
  end

  local inside = git_out("git rev-parse --is-inside-work-tree")
  if not inside or not inside:match("^true") then
    os_message("Not a Git work tree: skipping git clean")
  else
    local preview = git_out("git clean -xdn")
    if not preview or preview:match("^%s*$") then
      os_message("Nothing to clean with Git")
    else
      print("** git clean would remove:")
      io.write(preview)
      if options["dry-run"] then
        os_message("Dry run: nothing removed")
      else
        io.write("** Remove these files? [y/N] ")
        io.flush()
        local answer = (io.read("*l") or ""):lower():match("^%s*(%a*)%s*$") or ""
        if answer == "y" or answer == "yes" or answer == "s" or answer == "si" then
          os_message("Cleaning untracked repository files with Git")
          local res = os.execute("git clean -xdfq")
          if res ~= 0 and res ~= true then
            error("** Error!!: git clean failed")
          end
        else
          os_message("Skipping git clean")
        end
      end
    end
  end
  -- No ponemos os.exit() para que l3build continúe limpiando el directorio build/
end

-- Capture shell output safely (e.g. for Git queries)
local function os_capture(cmd, raw)
  local f = io.popen(cmd, "r")
  if not f then return "" end

  local s = f:read("*a") or ""
  f:close()

  if raw then return s end

  s = string.gsub(s, "^%s+", "")
  s = string.gsub(s, "%s+$", "")
  s = string.gsub(s, "[\n\r]+", " ")
  return s
end

-- Target "release": performs pre-release checks for Git and CTAN
if options["target"] == "release" then
  -- 1. Verify working branch is 'main'
  local gitbranch = os_capture("git symbolic-ref --short HEAD")
  if gitbranch == "main" then
    os_message("Checking git branch 'main'")
  else
    error("** Error!!: You must be on the 'main' branch (currently on '" .. gitbranch .. "')")
  end

  -- 2. Verify clean working directory (before generating any build files)
  local gitstatus = os_capture("git status --porcelain")
  if gitstatus == "" then
    os_message("Checking working directory status")
  else
    error("** Error!!: Uncommitted changes detected. Please commit all changes before release.")
  end

  -- 3. Verify local commits are pushed
  local gitpush = os_capture("git log --branches --not --remotes")
  if gitpush == "" then
    os_message("Checking pending commits")
  else
    error("** Error!!: There are unpushed local commits. Run 'git push' first.")
  end

  -- 4. Audit version/date consistency across all files
  if not check_all_tags() then
    error("** Error!!: Tag verification failed. Update build.lua or run 'l3build tag'")
  end

  -- 5. Test source extraction via luatex
  local file = jobname(sourcefiledir .. "/spintent.ins")
  local errorlevel = run(sourcefiledir, "luatex --interaction=batchmode " .. file .. ".ins > " .. os_null)
  if errorlevel ~= 0 then
    error("** Error!!: Failed to process " .. file .. ".ins with luatex")
  else
    os_message("Unpacking " .. file .. ".ins with luatex")
  end

  -- 6. Build CTAN package archive if absent
  if fileexists(ctanzip .. ".zip") then
    os_message("Checking CTAN package " .. ctanzip .. ".zip")
  else
    os_message("Building CTAN package " .. ctanzip .. ".zip")
    local res = os.execute("l3build ctan > " .. os_null)
    if res ~= 0 and res ~= true then
      error("** Error!!: 'l3build ctan' failed; nothing was tagged or pushed")
    end
  end

  -- 7. Perform CTAN upload dry run
  os_message("Running dry-run upload check")
  local res = os.execute("l3build upload -F ctan.ann --debug > " .. os_null)
  if res ~= 0 and res ~= true then
    error("** Error!!: dry-run upload check failed; nothing was tagged or pushed")
  end

  -- 8. Tag commit in Git (only after everything above succeeded)
  local tag_version = "v" .. pkgversion
  local tagongit = os_capture('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
  os_message("Checking latest Git tag (latest: " .. (tagongit ~= "" and tagongit or "none") .. ")")

  local tag_cmd = string.format('git tag -a %s -m "Release %s %s"', tag_version, tag_version, pkgdate)
  res = os.execute(tag_cmd)
  if res ~= 0 and res ~= true then
    error("** Error!!: Could not create Git tag " .. tag_version .. ". Verify if it already exists.")
  else
    os_message("Creating Git tag " .. tag_version)
  end

  os_message("Pushing Git tags to remote")
  res = os.execute("git push --tags --quiet")
  if res ~= 0 and res ~= true then
    error("** Error!!: 'git push --tags' failed. The tag " .. tag_version .. " exists locally; push it manually.")
  end

  print("-----------------------------------------------------------------")
  print("** Pre-release checks completed successfully!")
  print("** Review '" .. ctanzip .. ".curlopt' and verify 'ctan.ann'")
  print("** To publish to CTAN, run manually: l3build upload")
  print("-----------------------------------------------------------------")
  os.exit(0)
end
