# SampDiscordRPC (AML plugin for Nezuko SA-MP Android) - v0.1.0 pre-beta

Publishes GTA SA-MP activity to Discord Rich Presence. **Read STATUS first: this is not beta-ready.**

## STATUS (honest matrix)
| Feature | Implemented | Compiled | Runtime-verified |
|---|---|---|---|
| AML entry point (`__GetModInfo`, `OnModLoad`, `OnModUnload`) | yes | yes, ARM32 cross-compile with *stub* Android headers (not the NDK, not bionic) | **no** |
| Config parser (clamping, validation, privacy defaults) | yes | yes (host) | host unit tests pass |
| Presence builder (privacy, limits, sanitizing) | yes | yes (host) | host unit tests pass |
| RPC manager (single worker thread, dedupe, rate limit, bounded backoff, clear on stop) | yes | yes (host, ARM32 check) | host tests pass incl. ASan/UBSan + TSan |
| State bridge `SampRPC_Set*` C exports + session timer logic | yes | yes | host tests pass; **nothing calls it yet** |
| Reading server/nick/connection from Nezuko natively | **NO** - no verified source/offset | - | - |
| Lua feeder `lua/samprpc_bridge.lua` | skeleton, you must fill 3 functions | no | no |
| Discord Social SDK backend `src/discord_backend.cpp` | yes | syntax-checked against the real SDK header (ARM32), **not linked** | **no** |
| Actual presence on your Discord profile | **not achieved** | - | **no** |

Out of the box the plugin runs the "log-only" backend: it logs what it would publish and does **not** reach Discord.


## Pack layout
```
SampDiscordRPC/
  build.sh                 one-command build (both ABIs); uses third_party/ automatically
  Android.mk, Application.mk, main.cpp
  src/  include/           plugin source (+ include/iaml_130_abi.h: Nezuko AML 1.3.0 layout, 32-bit only)
  config/SampDiscordRPC.ini  default config
  lua/samprpc_bridge.lua   optional state feeder skeleton (untested)
  tests/                   host unit tests (make -C tests run)
  tools/setup_sdk.sh       extracts headers/libs/jars from YOUR Discord SDK download into third_party/discord_sdk
  tools/make_dex.sh        jar -> dex (needs d8; only for the future Java bootstrap)
  third_party/AndroidModLoader/   AML headers (MIT, included)
  third_party/discord_sdk/        empty: filled by tools/setup_sdk.sh (SDK is proprietary, not bundled)
  dist/install_to_phone/   where the built .so + ini example go on the phone
  docs/                    STAGE1 reports, STAGE3 SDK findings, status + test checklist
  BUILDING.md  README.md
```
## Quick start
```
export ANDROID_NDK_HOME=/path/to/ndk
tools/setup_sdk.sh /path/to/DiscordSocialSdk-1.10.19337.zip   # optional; skip for log-only
./build.sh
```
Output: `libs/armeabi-v7a/libSampDiscordRPC.so` (Nezuko, 32-bit only).

## Install (untested)
1. Launcher settings: Modloader ON; storage permission granted.
2. Copy `libSampDiscordRPC.so` to `<Android/data/com.nezukosamp.game>/mods/`.
3. Launch; check logcat tag `SampDiscordRPC`. The config file is searched in AML-provided directories and a default
   `SampDiscordRPC.ini` is written to the first writable one (which directory works is unverified; the log prints it).

## Discord setup (when SDK path is unblocked)
Create an application at the Developer Portal, enable the Social SDK, note the Application ID, upload art assets with
lowercase keys (`gtasa_logo`, `android` by default), put the ID in `[Discord] ApplicationId`.

## Config
See `config/SampDiscordRPC.ini`. Privacy defaults: server name shared, server address and nickname NOT shared.
Buttons: only your own `https://` URLs, max 2, shown only while connected. Never stores credentials.

## Known limitations
No native state source; Discord SDK feasibility on 32-bit ARM unknown; Discord must be installed and signed in;
abrupt process kill cannot clear presence; AML crash handling and config path unverified.


See `docs/STAGE3_SDK_FINDINGS.md`: the SDK DOES ship armeabi-v7a, but needs its Java classes loaded into the game process.
