# Based on

from pathlib import Path

from kitty.fast_data_types import Color, Screen
from kitty.tab_bar import DrawData, ExtraData, TabBarData, as_rgb
from kitty.utils import color_as_int

# Separators (rounded powerline style)
LEFT_SEP = ""
RIGHT_SEP = ""
SOFT_SEP = " │ "

# Colors
SOFT_SEP_COLOR = Color(89, 89, 89)


def shorten_path(title: str, max_components: int = 2) -> str:
    """Extract last N components from a path-like title."""
    # Handle common patterns: "vim filename", "~/path/to/dir", "/full/path"
    title = title.strip()

    # If it starts with a command (like "vim "), extract just the path part
    parts = title.split(None, 1)
    if len(parts) > 1 and parts[0] in ("vim", "nvim", "nano", "emacs", "code"):
        path_part = parts[1]
    else:
        path_part = title

    # Expand ~ and get path components
    if path_part.startswith("~"):
        path_part = path_part.replace("~", str(Path.home()), 1)

    # Split into components and take last N
    components = [c for c in path_part.split("/") if c]
    if len(components) > max_components:
        return "/".join(components[-max_components:])
    elif components:
        return "/".join(components)
    else:
        return title


def draw_tab(
    draw_data: DrawData,
    screen: Screen,
    tab: TabBarData,
    before: int,
    max_tab_length: int,
    index: int,
    is_last: bool,
    extra_data: ExtraData,
) -> int:
    """Draw a tab with custom styling and shortened titles."""

    # Extract and shorten title
    full_title = tab.title
    short_title = shorten_path(full_title)

    # Determine if this tab is active
    is_active = tab.is_active

    # Get colors
    default_bg = as_rgb(color_as_int(draw_data.default_bg))

    if is_active:
        fg = as_rgb(color_as_int(draw_data.active_fg))
        bg = as_rgb(color_as_int(draw_data.active_bg))
        icon = "󰅍"
    else:
        fg = as_rgb(color_as_int(draw_data.inactive_fg))
        bg = default_bg  # Use default background for inactive tabs
        icon = "󰨸"

    # Build tab content: icon + index + title
    tab_content = f"{icon} {index} {short_title}"

    # Calculate available space for content (minus separators)
    # LEFT_SEP and RIGHT_SEP are 3 bytes each but display as 1 char
    available_space = max_tab_length - 2  # Reserve space for separators

    # Truncate if needed
    if len(tab_content) > available_space:
        tab_content = tab_content[: available_space - 1] + "…"

    # Draw left separator
    screen.cursor.fg = bg
    screen.cursor.bg = default_bg
    screen.draw(LEFT_SEP)

    # Draw tab content
    screen.cursor.fg = fg
    screen.cursor.bg = bg
    screen.draw(tab_content)

    # Pad to fill max_tab_length
    content_width = len(LEFT_SEP) + len(tab_content)
    padding_needed = (
        max_tab_length - content_width - len(RIGHT_SEP) - (1 if not is_last else 0)
        # On the last tab, no soft separator
    )

    if padding_needed > 0:
        screen.draw(" " * (padding_needed - 2)) # add less padding for now due to bug

    # Draw right separator
    screen.cursor.fg = bg
    screen.cursor.bg = default_bg
    screen.draw(RIGHT_SEP)
    if not is_last:
        fg = as_rgb(color_as_int(SOFT_SEP_COLOR))
        screen.cursor.fg = fg
        screen.draw(SOFT_SEP)

    return screen.cursor.x
