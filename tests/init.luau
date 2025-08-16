local test_list = {
	"three-vector3values",
	"default-inserted-folder",
}

local INPUT_BASE = "rbx-test-files/models/%s/binary.rbxm"
local OUTPUT_BASE = "tests/output/%s.rbxm"

local fs = require("@lune/fs")
local process = require("@lune/process")

local rbx_binary = require("../src")

process.exec("cargo", {
	"build",
})

local failures: { [string]: string } = {}

for _, test in test_list do
	local content = fs.readFile(string.format(INPUT_BASE, test))
	local dom = rbx_binary.decode(buffer.fromstring(content))
	-- TODO: snapshot decoding :3

	local encoded = rbx_binary.encode(dom, "None")
	fs.writeFile(string.format(OUTPUT_BASE, test), encoded)
	local result = process.exec("cargo", {
		"run",
		"--locked",
		"--",
		test,
	})

	if not result.ok then
		failures[test] = result.stderr
	end
end

local failed = false
for _, test in test_list do
	local failure_message = failures[test]
	if failure_message then
		print(`[❌] {test} failed!`)
		-- print(failure_message)
	else
		print(`[✔] {test} passed`)
	end
end

if failed then
	process.exit(1)
else
	process.exit(0)
end
