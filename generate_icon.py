import os
from PIL import Image, ImageDraw


def create_app_icon():
    # Folder create karein agar na ho
    os.makedirs("assets/icon", exist_ok=True)

    size = 512
    image = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    # Dark Theme Outer Background Circle (Google Blue Accent)
    bg_color = (30, 136, 229, 255)  # #1E88E5
    draw.ellipse([20, 20, 492, 492], fill=bg_color)

    # Subtle Ring Border
    draw.ellipse([45, 45, 467, 467], outline=(255, 255, 255, 50), width=6)

    # Bold White Checkmark (Task Check Symbol)
    checkmark_points = [
        (160, 260),
        (230, 330),
        (355, 195),
    ]
    draw.line(
        checkmark_points,
        fill=(255, 255, 255, 255),
        width=38,
        joint="curved",
    )

    # Save PNG File
    output_path = "assets/icon/app_icon.png"
    image.save(output_path, "PNG")
    print(f"PNG Logo successfully generated at: {output_path}")


if __name__ == "__main__":
    create_app_icon()
