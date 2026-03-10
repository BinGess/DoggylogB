from pathlib import Path
from typing import List, Optional

from reportlab.lib.colors import HexColor
from reportlab.lib.pagesizes import A4
from reportlab.pdfbase.pdfmetrics import stringWidth
from reportlab.pdfgen import canvas


PAGE_WIDTH, PAGE_HEIGHT = A4
MARGIN = 34
GUTTER = 18
COLUMN_WIDTH = (PAGE_WIDTH - (MARGIN * 2) - GUTTER) / 2

TEXT = {
    "title": "DoggyLog App Summary",
    "subtitle": "Repo-based, one-page overview",
    "what_it_is": (
        "DoggyLog is a Flutter mobile app that combines a pet-focused calendar, "
        "countdown tracker, and companion-style pet profile experience in one interface. "
        "The repo also includes native hooks for notifications, biometrics, geofencing, "
        "iOS calendar sync, and widget snapshot publishing."
    ),
    "who_its_for": (
        "Primary persona: pet owners, especially dog owners, who want one place to manage "
        "care schedules, milestones, reminders, and a lightweight companion avatar."
    ),
    "what_it_does": [
        "Onboards the user by choosing a pet breed and nickname.",
        "Shows a calendar with week or month views, date selection, and agenda items.",
        "Creates, edits, completes, and deletes calendar tasks with reminder offsets.",
        "Tracks countdown items with pinned status, progress, and celebration state.",
        "Manages pet profiles, active companion selection, loyalty points, and unlockable skins.",
        "Schedules local notifications for upcoming tasks and supports biometric app unlock.",
        "Offers iOS calendar sync plus geofence-based scene updates when permissions are granted.",
    ],
    "how_it_works": [
        "UI layer: Flutter screens such as Onboarding, HomeShell, Calendar, Countdown, Settings, and Pets consume appStateProvider.",
        "State layer: AppStateController bootstraps app data, listens to repository streams, and coordinates reminders, permissions, sync, sensors, and snapshots.",
        "Data layer: AppRepository uses Drift tables for calendar entries, pets, countdowns, geofences, loyalty ledger, and key-value preferences, plus SharedPreferences for seed flags.",
        "Platform layer: service wrappers call DoggylogPlatform, which uses a MethodChannel for calendar, notifications, biometrics, sensors, widget snapshots, and Dynamic Island updates.",
        "Data flow: user action -> controller -> repository/database; state changes -> notification sync and shared snapshot publishing for native surfaces.",
        "Not found in repo: fully wired CloudKit backup flow. iOS widget extension files exist, but ios/Extensions/README says they are not yet wired into Runner.xcodeproj.",
    ],
    "how_to_run": [
        "Install Flutter. Repo evidence: pubspec.yaml targets Dart 3.10.8; local tool check found Flutter 3.38.9.",
        "From the project root, run: flutter pub get",
        "Start the app on a simulator or device: flutter run",
        "Optional verification: flutter test",
        "Not found in repo: project-specific setup notes beyond the default Flutter starter README.",
    ],
    "footer": (
        "Evidence source set: pubspec.yaml, lib/main.dart, lib/core/bootstrap.dart, "
        "lib/app/app.dart, lib/app/router/app_router.dart, lib/features/*, "
        "lib/platform/*, ios/Extensions/README.md."
    ),
}


def wrap_text(
    text: str, font_name: str, font_size: float, max_width: float
) -> List[str]:
    words = text.split()
    lines: List[str] = []
    current = ""
    for word in words:
        candidate = word if not current else f"{current} {word}"
        if stringWidth(candidate, font_name, font_size) <= max_width:
            current = candidate
            continue
        if current:
            lines.append(current)
        current = word
    if current:
        lines.append(current)
    return lines


def draw_rule(pdf: canvas.Canvas, x: float, y: float, width: float) -> None:
    pdf.setStrokeColor(HexColor("#D7DEE6"))
    pdf.setLineWidth(1)
    pdf.line(x, y, x + width, y)


def draw_section(
    pdf: canvas.Canvas,
    x: float,
    y: float,
    width: float,
    title: str,
    body: Optional[str] = None,
    bullets: Optional[List[str]] = None,
) -> float:
    pdf.setFillColor(HexColor("#14324A"))
    pdf.setFont("Helvetica-Bold", 12)
    pdf.drawString(x, y, title)
    y -= 8
    draw_rule(pdf, x, y, width)
    y -= 12

    if body:
        pdf.setFillColor(HexColor("#203647"))
        pdf.setFont("Helvetica", 10.0)
        for line in wrap_text(body, "Helvetica", 10.0, width):
            pdf.drawString(x, y, line)
            y -= 11.8
        y -= 5

    if bullets:
        pdf.setFillColor(HexColor("#203647"))
        for bullet in bullets:
            bullet_lines = wrap_text(bullet, "Helvetica", 9.5, width - 12)
            if not bullet_lines:
                continue
            pdf.setFont("Helvetica", 9.5)
            pdf.drawString(x, y, "-")
            pdf.drawString(x + 10, y, bullet_lines[0])
            y -= 11.2
            for line in bullet_lines[1:]:
                pdf.drawString(x + 10, y, line)
                y -= 11.2
            y -= 2.8
        y -= 1

    return y


def generate_pdf(output_path: Path) -> None:
    output_path.parent.mkdir(parents=True, exist_ok=True)
    pdf = canvas.Canvas(str(output_path), pagesize=A4)
    pdf.setTitle("DoggyLog App Summary")

    pdf.setFillColor(HexColor("#0F2740"))
    pdf.setFont("Helvetica-Bold", 22)
    pdf.drawString(MARGIN, PAGE_HEIGHT - MARGIN, TEXT["title"])
    pdf.setFillColor(HexColor("#5B7083"))
    pdf.setFont("Helvetica", 10)
    pdf.drawString(MARGIN, PAGE_HEIGHT - MARGIN - 15, TEXT["subtitle"])
    draw_rule(pdf, MARGIN, PAGE_HEIGHT - MARGIN - 24, PAGE_WIDTH - (MARGIN * 2))

    left_x = MARGIN
    right_x = MARGIN + COLUMN_WIDTH + GUTTER
    left_y = PAGE_HEIGHT - MARGIN - 42
    right_y = left_y

    left_y = draw_section(
        pdf,
        left_x,
        left_y,
        COLUMN_WIDTH,
        "What It Is",
        body=TEXT["what_it_is"],
    )
    left_y = draw_section(
        pdf,
        left_x,
        left_y,
        COLUMN_WIDTH,
        "Who It Is For",
        body=TEXT["who_its_for"],
    )
    left_y = draw_section(
        pdf,
        left_x,
        left_y,
        COLUMN_WIDTH,
        "What It Does",
        bullets=TEXT["what_it_does"],
    )
    left_y = draw_section(
        pdf,
        left_x,
        left_y,
        COLUMN_WIDTH,
        "How To Run",
        bullets=TEXT["how_to_run"],
    )

    right_y = draw_section(
        pdf,
        right_x,
        right_y,
        COLUMN_WIDTH,
        "How It Works",
        bullets=TEXT["how_it_works"],
    )

    footer_y = 48
    draw_rule(pdf, MARGIN, footer_y + 14, PAGE_WIDTH - (MARGIN * 2))
    pdf.setFillColor(HexColor("#61788C"))
    pdf.setFont("Helvetica", 8.4)
    for line in wrap_text(TEXT["footer"], "Helvetica", 8.4, PAGE_WIDTH - (MARGIN * 2)):
        pdf.drawString(MARGIN, footer_y, line)
        footer_y -= 9.5

    pdf.save()


if __name__ == "__main__":
    generate_pdf(Path("output/pdf/doggylog-app-summary.pdf"))
