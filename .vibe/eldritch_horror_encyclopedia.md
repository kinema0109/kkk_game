# Eldritch Horror Wikipedia (Base Game) 🐙🕰️

Đây là kho dữ liệu tổng hợp về toàn bộ thành phần, luật chơi và danh sách các thẻ bài của Eldritch Horror (phiên bản gốc). File này được lưu tại `.vibe/` để AI luôn có thể truy cập và đối soát dữ liệu trong quá trình lập trình.

---

## 1. Luật chơi & Vòng lặp (Core Rules & Loop)

### Giai đoạn 1: Action Phase (Hành động)
Mỗi điều tra viên được thực hiện tối đa **2 hành động khác nhau**:
- **Travel**: Di chuyển đến ô liền kề. Có thể tiêu vé (Ticket) để di chuyển thêm.
- **Rest**: Hồi 1 Máu và 1 Sanity (nếu không có quái vật tại ô đó).
- **Trade**: Trao đổi trang bị với điều tra viên khác cùng ô.
- **Acquire Assets**: Test **Influence** để mua đồ từ hàng chờ (Reserve).
- **Prepare for Travel**: Lấy 1 vé (Tàu hỏa/Tàu thủy) nếu đang ở Thành phố.
- **Component Action**: Thực hiện hành động ghi trên thẻ bài hoặc tờ nhân vật.

### Giai đoạn 2: Encounter Phase (Sự kiện)
- **Combat Encounter**: Phải đánh hết quái vật tại ô (test Will để tránh mất Sanity, test Strength để gây sát thương).
- **Location Encounter**: Rút thẻ tại ô (City, Wilderness, Sea).
- **Research Encounter**: Giải quyết tại ô có Manh mối (Clue) để lấy Manh mối.
- **Other World Encounter**: Giải quyết tại ô có Cổng (Gate) để đóng cổng.
- **Expedition Encounter**: Giải quyết tại vị trí Thám hiểm để lấy Artifact.

### Giai đoạn 3: Mythos Phase (Huyền bí)
Kích hoạt các biểu tượng trên thẻ Mythos:
1. **Advance Omen**: Tiến Doom track nếu chòm sao trùng khớp.
2. **Resolve Reckoning**: Kích hoạt hiệu ứng đỏ (Conditions, Monsters, Ancient One).
3. **Spawn Gates / Clues / Monsters**.
4. **Resolve Event**: Thực hiện nội dung sự kiện trên thẻ.

---

## 2. Điều tra viên (12 Investigators)

1. **Leo Anderson (Expedition Leader)**: Chuyên gia thám hiểm, lấy Artifact dễ hơn.
2. **Akachi Onyele (Shaman)**: Chuyên đóng cổng và dùng phép.
3. **Diana Stanley (Redeemed Cultist)**: Mạnh về Will, khắc tinh của quái vật ma thuật.
4. **Norman Withers (Astronomer)**: Đọc chòm sao, đóng cổng từ xa.
5. **Silas Marsh (Sailor)**: Vua của các vùng biển, di chuyển nhanh.
6. **Trish Scarborough (Spy)**: Thu thập Clue và né tránh quái vật.
7. **Charlie Kane (Politician)**: Đứng một chỗ mua đồ cho toàn team.
8. **Lily Chen (Martial Artist)**: Tăng chỉ số Strength cực nhanh.
9. **Lola Hayes (Actress)**: Đa năng, có thể đổi vai trò (chỉ số).
10. **Jim Culver (Musician)**: Khả năng hồi Sanity và dùng nhạc cụ.
11. **Jacqueline Fine (Psychic)**: Dự đoán Mythos và hỗ trợ Clue từ xa.
12. **Mark Harrigan (Soldier)**: Cỗ máy chiến đấu, hồi máu khi diệt quái.

---

## 3. Đại Cổ Thần (4 Ancient Ones) & Mystery

### Azathoth (The Daemon Sultan)
- **Difficulty**: Dễ.
- **Mysteries**:
    1. **Occult Research**: Cần tích số Manh mối = số người chơi.
    2. **Seed of the Daemon Sultan**: Đặt Eldritch token tại Tunguska.
    3. **The True Name**: Tìm kiếm tên thật của Cổ Thần.
    4. **The Comet**: Sự kiện thiên thạch.

### Cthulhu (The Great Dreamer)
- **Difficulty**: Khó.
- **Mysteries**:
    1. **Awakening the Dreamer**: Di chuyển Manh mối ra biển và thu thập.
    2. **Queen of the Deep Ones**: Đánh Epic Monster.
    3. **Threatening Seas**: Giải quyết thảm họa đại dương.
    4. **The Call of Cthulhu**: Sự kiện giấc mơ kinh hoàng.

### Shub-Niggurath (Black Goat of the Woods)
- **Difficulty**: Trung bình.
- **Mysteries**:
    1. **Whispers in the Wilderness**: Tìm manh mối trong rừng sâu.
    2. **Spawn of the Black Goat**: Tiêu diệt đám con nghiệt ngã.
    3. **Hunting the Thousand**: Diệt số lượng quái vật nhất định.
    4. **Rituals in the Wild**: Phá hủy các buổi tế lễ.

### Yog-Sothoth (Lurker at the Threshold)
- **Difficulty**: Khó.
- **Mysteries**:
    1. **Sealing the Rifts**: Đóng Cổng và dùng Phép thuật.
    2. **The Dunwich Horror**: Tiêu diệt quái vật Dunwich tại Arkham.
    3. **Harnessing Eldritch Power**: Dùng Eldritch token tích lũy qua Spell.
    4. **Unraveling Reality**: Giải quyết các Research encounter.

---

## 4. Danh sách Thẻ bài (Card Inventory)

### Spells (20 thẻ)
- *Loại*: **Incantation** (Dùng bất cứ lúc nào), **Ritual** (Tốn 1 hành động).
- **Abilities Tiêu biểu**:
    - **Feed the Mind**: Test Lore. Thành công: 1 điều tra viên tại ô đó nhận +1 cho 1 Stat bất kỳ.
    - **Flesh Ward**: Dùng khi chịu sát thương (Stamina). Giảm lượng máu mất đi.
    - **Healing Words**: Hồi Stamina cho bản thân hoặc người cùng ô.
    - **Shrivelling**: Dùng trong Combat. Test Lore để gây sát thương cực mạnh cho Quái vật.
    - **Mists of Releh**: Dùng trong Encounter. Test Lore để bỏ qua Combat Encounter và thực hiện Location Encounter ngay lập tức.

### Assets (40 thẻ)
- **Vũ khí**:
    - **.38 Auto**: +1 Strength khi Combat.
    - **Double-Barreled Shotgun**: +3 Strength khi Combat.
- **Vật dụng**:
    - **Whiskey**: Hồi 1 Sanity (Hành động).
    - **Pocket Watch**: Cho phép thực hiện thêm 1 hành động khác nếu đang ở Thành phố.
- **Đồng minh**:
    - **Cat Burglar**: +1 Observation. Cho phép rút 2 thẻ Encounter và chọn 1 khi ở Thành phố.
- **Dịch vụ**:
    - **Charter Flight**: Di chuyển đến bất kỳ Thành phố nào trên bản đồ (Tốn 1 hành động).

### Artifacts (14 thẻ)
- **Necronomicon**: +2 Lore. Hành động: Test Lore để đóng 1 Cổng tại ô bất kỳ (Rất mạnh nhưng dễ mất Sanity).
- **The Silver Key**: +2 Observation. Bỏ qua các hiệu ứng xấu khi đóng Cổng.
- **Ruby of R'lyeh**: +2 Strength & +2 Will. Kẻ thù không thể hồi máu.

### Conditions (36 thẻ)
- **Cursed**: Khi đổ xúc xắc, chỉ có mặt **6** mới thành công (thay vì 5, 6).
- **Blessed**: Khi đổ xúc xắc, mặt **4, 5, 6** đều thành công.
- **Debt**: Khi lật mặt sau trong Reckoning, có thể bị mất tài sản hoặc bị bắt giam.
- **Injured**: Giảm chỉ số Strength hoặc không thể thực hiện hành động di chuyển xa.

---

## 5. Bản đồ thế giới (Global Map Layout)

Bản đồ là trái tim của Eldritch Horror. Nó không chỉ là hình ảnh mà là một **Đồ thị (Graph)** của các địa điểm.

### Loại địa điểm:
- **Major Cities** (Thành phố): Arkham, London, Rome, Istanbul, Shanghai, Tokyo, San Francisco, Buenos Aires, Sydney. (Nơi mua sắm Assets).
- **Wilderness** (Hoang dã): Amazon, Heart of Africa, Himalayas, Tunguska, Pyramids.
- **Sea** (Biển): Các vùng đại dương rộng lớn nối giữa các lục địa.

### Các loại đường nối (Paths):
- **Unbroken Path**: Di chuyển bộ (thường nối các địa danh gần nhau).
- **Rail Path** (Đường sắt): Cần 1 vé Tàu hỏa (Train Ticket) để di chuyển thêm 1 ô đường sắt.
- **Ship Path** (Đường thủy): Cần 1 vé Tàu thủy (Ship Ticket) để di chuyển thêm 1 ô đường thủy.

---

## 6. Hình ảnh & Tài nguyên (Assets Generation)

Vì lý do bản quyền, chúng ta sẽ không lấy ảnh trực tiếp từ board game mà sẽ **Generate (tạo mới)** bằng AI để đảm bảo tính độc bản và thẩm mỹ cao:
- **Card Art**: Sử dụng prompt phong cách Lovecraft/Noir (Ví dụ: "Antique occult tome on a dark wooden table, sepia tone, cinematic lighting").
- **Map Tiles**: Tạo các mảnh bản đồ phong cách giấy da cũ (parchment) với các biểu tượng cổ xưa.
- **Icons**: Token Clue, Sanity, Health sẽ được thiết kế đồng bộ theo phong cách "Forbidden Archive".
