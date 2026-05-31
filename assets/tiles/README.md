# Tile PNG 목록 (assets/tiles/)

게임은 **`assets/tiles/{spriteId}.png`** 경로에서 PNG를 읽습니다.  
파일이 없으면 코드 기본 그래픽(procedural)으로 표시됩니다.

## 공통 규칙

| 항목 | 설명 |
|------|------|
| **파일명** | `{spriteId}.png` (대소문자·밑줄 정확히) |
| **크기** | 정사각형 권장 (48×48 필수 아님, 64~128 등 OK) |
| **투명 배경** | 플레이어·건물·NPC·몬스터는 PNG 알파 채널 권장 |
| **빌드** | PNG 사용 시 `libsdl2-image-dev` + `make` 시 `-lSDL2_image` 필요 |
| **실행 cwd** | 레포 **루트**에서 `./build/main` (또는 `./main`) — `assets/` 가 상대 경로 기준 |

---

## ★ 우선 만들면 좋은 것 (11장)

| 파일명 | 설명 |
|--------|------|
| `terrain_mars_rough.png` | 야외 화성 땅 (가장 넓게 보임) |
| `terrain_base_floor.png` | 메인 기지 실내 바닥 |
| `terrain_road.png` | 도로 타일 |
| `terrain_farm_soil.png` | 농지 토양 (노란 흙, 농장 아래) |
| `player.png` | 우주비행사 (투명 PNG) |
| `farm_plot.png` | 농장 (#) |
| `bed.png` | 침대 (B) — 하루 넘기기 |
| `store.png` | 상점 ($) |
| `fishing_spot.png` | 낚시터 (F) |
| `cattle_plot.png` | 축사 (A) |
| `ruined_lab.png` | 폐연구소 (X) |

`terrain_mars_base.png` 는 `terrain_base_floor` **별칭** (둘 중 하나만 있어도 됨).

---

## 1. 바닥·지형 (terrain)

| 파일명 | spriteId | 설명 |
|--------|----------|------|
| `terrain_base_floor.png` | `terrain_base_floor` | 메인 기지 실내 바닥 |
| `terrain_mars_base.png` | *(별칭)* | 위와 동일 (코드가 자동으로 시도) |
| `terrain_mars_rough.png` | `terrain_mars_rough` | 좌/상/Space4 야외 기본 땅 |
| `terrain_road.png` | `terrain_road` | 맵 연결 도로 |
| `terrain_farm_soil.png` | `terrain_farm_soil` | 농장 타일 아래 깔리는 흙 |
| `terrain_empty.png` | `terrain_empty` | 빈 지형 (거의 미사용) |

---

## 2. 플레이어

| 파일명 | spriteId | 설명 |
|--------|----------|------|
| `player.png` | `player` | 일반 우주비행사 |
| `player_tank.png` | `player_tank` | 탱크 모드 (세계대전 연구, Space 4, S키) |

---

## 3. 건물·시설

| 파일명 | spriteId | 게임 표시 | 설명 |
|--------|----------|-----------|------|
| `farm_plot.png` | `farm_plot` | # | 완공된 농장 |
| `cattle_plot.png` | `cattle_plot` | A | 축사 |
| `store.png` | `store` | $ | 상점 |
| `bed.png` | `bed` | B | 침대 |
| `fishing_spot.png` | `fishing_spot` | F | 낚시터 |
| `research_lab.png` | `research_lab` | R | 연구소 (완공·수리 후) |
| `ruined_lab.png` | `ruined_lab` | X | 폐연구소 (수리 전) |
| `plant_lab.png` | `plant_lab` | V | 식물 연구소 |
| `animal_lab.png` | `animal_lab` | L | 동물 연구소 |
| `oxygen_bank.png` | `oxygen_bank` | O | 산소 은행 |
| `rocket_wreckage.png` | `rocket_wreckage` | r | 로켓 잔해 |
| `rocket_built.png` | `rocket_built` | R | 완성된 로켓 |
| `building_construction_base.png` | `building_construction_base` | * | **건설 중** (농장·상점·침대 등 공통) |
| `door_in.png` | `door_in` | H | 가옥 / 기지 출입 (HouseBuilding) |

---

## 4. NPC·기타 오브젝트

| 파일명 | spriteId | 설명 |
|--------|----------|------|
| `baby_alien_object.png` | `baby_alien_object` | 맵에 스폰되는 아기 외계인 (a) |
| `merchant.png` | `merchant` | 경제학 연구 후 상단 맵 상인 (M) |

---

## 5. 몬스터 (Space 4) — 선택

spriteId = `monster_` + **몬스터 이름(공백 포함)**  
없으면 빨간 기본 박스. **전부 만들 필요 없음.**

| 파일명 | 몬스터 |
|--------|--------|
| `monster_Alien Slime.png` | Alien Slime |
| `monster_Red Slime.png` | Red Slime |
| `monster_Spike Insect.png` | Spike Insect |
| `monster_Corrupted Crab.png` | Corrupted Crab |
| `monster_Acid Spitter.png` | Acid Spitter |
| `monster_Dust Devil.png` | Dust Devil |
| `monster_Martian Hulk.png` | Martian Hulk |
| `monster_Shadow Stalker.png` | Shadow Stalker |
| `monster_Acid Hurler.png` | Acid Hurler |
| `monster_Cyber Claw.png` | Cyber Claw |
| `monster_Plasma Spitter.png` | Plasma Spitter |
| `monster_Void Ripper.png` | Void Ripper |
| `monster_Void Goliath.png` | Void Goliath |
| `monster_Heavy Plasma Spitter.png` | Heavy Plasma Spitter |
| `monster_Void Carnivore.png` | Void Carnivore |
| `monster_Mars Overlord.png` | Mars Overlord |
| `monster_Orbital Broodseer.png` | Orbital Broodseer |

> 몬스터 PNG는 **파일명에 공백**이 들어갑니다.  
> 예: `monster_Alien Slime.png`

---

## 그리기 순서 (레이어)

1. **바닥** (`terrain_*`)  
2. **오브젝트** (낚시터, 상점 등 — 플레이어 발 아래)  
3. **플레이어** (`player.png`)

플레이어가 낚시터·상점 위에 서도 오브젝트가 가려지지 않도록 렌더러가 위 순서로 그립니다.

---

## 전체 파일 체크리스트 (35 + 몬스터 17)

**지형 6 · 플레이어 2 · 건물 14 · NPC 2 · 몬스터 17 (선택)**

```
terrain_base_floor.png
terrain_mars_base.png          ← 별칭, 선택
terrain_mars_rough.png
terrain_road.png
terrain_farm_soil.png
terrain_empty.png
player.png
player_tank.png
farm_plot.png
cattle_plot.png
store.png
bed.png
fishing_spot.png
research_lab.png
ruined_lab.png
plant_lab.png
animal_lab.png
oxygen_bank.png
rocket_wreckage.png
rocket_built.png
building_construction_base.png
door_in.png
baby_alien_object.png
merchant.png
(+ monster_*.png 17종, 선택)
```

---

## 빌드·실행 참고

```bash
# Ubuntu/WSL — PNG 지원 빌드
sudo apt install -y libsdl2-image-dev
pkg-config --libs SDL2_image    # -lSDL2_image 출력 확인
make clean && make              # 링크 줄에 -lSDL2_image 확인
```

PNG 추가·이름 변경 후에는 **게임 재시작** (`./main` 또는 `./build/main`).
