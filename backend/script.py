from PIL import Image
import os

# Đường dẫn ảnh gốc và thư mục lưu
input_path = r"E:\image\deception\httpssteamusercontentaakamaihdnetugc776246531179120972AD4C01AAB97F1D4CCD024987273D412D3E63CC92.png"
output_dir = r"E:\image\deception"

if not os.path.exists(output_dir):
    os.makedirs(output_dir)

img = Image.open(input_path)
width, height = img.size

# Tính toán kích thước mỗi ô (Giả sử lưới 3 hàng x 5 cột)
cols = 5
rows = 3
cell_width = width // cols
cell_height = height // rows

# Danh sách tên file tương ứng (theo thứ tự từ trái qua phải, từ trên xuống dưới)
names = [
    "axe", "blood_release", "whip", "plastic_bag", "injection",
    "bite_and_tear", "e_bike", "mad_dog", "folding_chair", "machine",
    "kick", "plague", "radiation", "sculpture", "means_question_1"
]
idx = 0
for r in range(rows):
    for c in range(cols):
        left = c * cell_width
        top = r * cell_height
        right = (c + 1) * cell_width
        bottom = (r + 1) * cell_height
        
        # Cắt và lưu
        tile = img.crop((left, top, right, bottom))
        tile.save(os.path.join(output_dir, f"{names[idx]}.png"))
        idx += 1

print("Đã cắt xong 15 ảnh!")