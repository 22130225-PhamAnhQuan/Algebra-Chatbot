import io
import base64
import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


class GraphUtils:
    @staticmethod
    def create_axes(title=""):
        # Tỉ lệ khung hình vuông giúp đồ thị toán học cân đối hơn
        fig, ax = plt.subplots(figsize=(6, 6))

        # 1. BIẾN HÌNH THÀNH TRỤC TỌA ĐỘ CHUẨN SGK:
        # Ẩn đường viền khung trên và phải
        ax.spines['top'].set_color('none')
        ax.spines['right'].set_color('none')

        # Di chuyển trục trái và dưới vào chính giữa gốc tọa độ (0, 0)
        ax.spines['left'].set_position('zero')
        ax.spines['bottom'].set_position('zero')

        # 2. VẼ MŨI TÊN CHỈ HƯỚNG CHO TRỤC Ox, Oy
        ax.plot((1), (0), ls="", marker=">", ms=8, color="k", transform=ax.get_yaxis_transform(), clip_on=False)
        ax.plot((0), (1), ls="", marker="^", ms=8, color="k", transform=ax.get_xaxis_transform(), clip_on=False)

        # 3. GẮN NHÃN Ox, Oy VÀ GỐC TỌA ĐỘ O
        ax.set_xlabel('x', size=12, fontstyle='italic')
        ax.set_ylabel('y', size=12, fontstyle='italic', rotation=0)
        ax.xaxis.set_label_coords(1.05, 0.5)  # Kéo chữ x ra sát mũi tên
        ax.yaxis.set_label_coords(0.53, 1.05)  # Kéo chữ y lên sát mũi tên trên cùng

        ax.text(-0.3, -0.3, 'O', fontsize=12, fontstyle='italic')

        ax.grid(True, linestyle="--", alpha=0.4)

        if title:
            ax.set_title(title, pad=20, fontweight="bold")

        return fig, ax

    @staticmethod
    def mark_point(ax, x, y, label=None):
        ax.scatter([x], [y], color="red", zorder=5)

        if x != 0 and y != 0:
            ax.plot([x, x], [0, y], color="gray", linestyle=":", linewidth=1.5, zorder=4)
            ax.plot([0, x], [y, y], color="gray", linestyle=":", linewidth=1.5, zorder=4)

        if label:
            ax.annotate(
                label,
                (x, y),
                textcoords="offset points",
                xytext=(8, 8),
                ha='left',
                fontsize=11,
                fontweight='bold'
            )

    @staticmethod
    def to_base64(fig):
        buffer = io.BytesIO()
        fig.savefig(buffer, format="png", bbox_inches="tight", dpi=150)
        plt.close(fig)
        buffer.seek(0)
        return base64.b64encode(buffer.read()).decode()