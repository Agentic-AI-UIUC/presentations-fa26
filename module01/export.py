"""Export module 01 with a centered canvas, illustrated title, and progress footer."""

from pathlib import Path
from html import escape
import json
import re
import subprocess
import sys


def center_canvas(html):
    # The upstream scaler fits the canvas but anchors it at the top-left.
    old = 'document.querySelector("body").style.transform = `scale(${scaledAmount})`;'
    new = '''const canvas = document.body;
    canvas.style.position = "fixed";
    canvas.style.left = `${(w - originalWidth * scaledAmount) / 2}px`;
    canvas.style.top = `${(h - originalHeight * scaledAmount) / 2}px`;
    canvas.style.transform = `scale(${scaledAmount})`;'''
    if new in html:
        return html
    if html.count(old) != 1:
        raise ValueError("Presenterm export changed; inspect its scaler before patching.")
    html = html.replace(old, new)
    if 'name="viewport"' not in html:
        html = html.replace('</head>', '<meta name="viewport" content="width=device-width,initial-scale=1"></head>')
    return html


def style_footer(html):
    if 'id="deck-footer-style"' in html:
        return html
    pattern = (r'<div class="content-line"><pre>[^\n]*AGENTICAIUIUC\.COM[^\n]*?'
               r'<span style="[^"]*">(\d+)</span><span style="[^"]*"> / (\d+)</span>'
               r'\s*</pre></div>')

    def progress(match):
        current, total = map(int, match.groups())
        return (
            '<div class="content-line"><footer class="deck-footer">'
            '<span>AGENTIC AI @ UIUC · AGENTICAIUIUC.COM</span>'
            '<span class="deck-progress">'
            f'<progress aria-label="Slide progress" value="{current}" max="{total}"></progress>'
            f'<span class="slide-count"><span class="slide-current">{current}</span>'
            f'<span> / {total}</span></span></span></footer></div>'
        )

    html, count = re.subn(pattern, progress, html)
    if count != html.count('<div class="container">') or not count:
        raise ValueError("Expected one footer per exported page; inspect export before patching.")
    html = html.replace('AGENTICAIUIUC.COM',
        '<a class="club-link" href="https://agenticaiuiuc.com" target="_blank" '
        'rel="noopener noreferrer">AGENTICAIUIUC.COM</a>')
    return html.replace('</head>', '''<style id="deck-footer-style">
    .container { position: relative; }
    .club-link { background: #f25c14; color: #0d0d0d; padding: 0 3px; text-decoration: none; }
    .club-link:hover { text-decoration: underline; }
    .club-link:focus-visible { outline: 1px solid #f2f2f2; outline-offset: 2px; }
    .deck-footer { position: absolute; left: 6%; right: 6%; bottom: 12px;
        display: flex; align-items: center; justify-content: space-between; gap: 16px;
        color: #6b6b6b; font: 10px/12px monospace; white-space: nowrap; }
    .deck-progress { display: flex; align-items: center; gap: 10px;
        font-variant-numeric: tabular-nums; }
    .slide-count { white-space: pre; }
    .slide-current { color: #f25c14; }
    .deck-progress progress { appearance: none; border: 0; border-radius: 2px;
        overflow: hidden; width: 80px; height: 3px; background: #2e2e2e; }
    .deck-progress progress::-webkit-progress-bar { background: #2e2e2e; }
    .deck-progress progress::-webkit-progress-value { background: #f25c14; }
    .deck-progress progress::-moz-progress-bar { background: #f25c14; }
    </style></head>''')


def add_title_graphic(html, metadata):
    if 'class="title-layout"' in html:
        return html
    before, first, rest = html.split('<div class="container">', 2)
    lines = re.findall(r'<div class="content-line">(.*?)</div>', first, re.S)
    # Use source metadata, not wrapped terminal lines, so export width cannot
    # change which text becomes the title, subtitle, or date.
    module, title = metadata['title'].split(' · ', 1)
    module, title, subtitle, event, date = map(escape, (
        module, title, metadata['sub_title'], metadata['event'], metadata['date']))
    graphic = Path(__file__).with_name('agent-loop.svg').read_text()
    first = (f'<section class="title-layout"><p class="module-label">{module}</p>'
             f'<h1>{title}</h1><p class="subtitle">{subtitle}</p>{graphic}'
             f'<p class="event">{event}<br>{date}</p></section>'
             + '<div class="content-line"></div>' * (len(lines) - 2)
             + ''.join(f'<div class="content-line">{line}</div>' for line in lines[-2:])
             + '</div>\n')
    html = before + '<div class="container">' + first + '<div class="container">' + rest
    return html.replace('</head>', '''<style>
    .title-layout { position: absolute; inset: 20px 6% 46px; display: flex;
        flex-direction: column; align-items: center; gap: 8px;
        text-align: center; font-family: monospace; color: #f2f2f2; }
    .title-layout p, .title-layout h1 { margin: 0; }
    .title-layout .module-label { color: #f25c14; font-size: 12px;
        line-height: 18px; letter-spacing: 3px; }
    .title-layout h1 { max-width: 680px; font-size: 24px; line-height: 28px; font-weight: bold; }
    .title-layout .subtitle { font-size: 10px; line-height: 15px; }
    .title-layout svg { width: 82%; flex: 1; min-height: 0; }
    .title-layout .event { color: #f25c14; font-size: 10px; line-height: 15px; }
    </style></head>''')


if __name__ == "__main__":
    if sys.argv[1:] == ["--check"]:
        marker = 'document.querySelector("body").style.transform = `scale(${scaledAmount})`;'
        fixed = center_canvas(marker)
        assert "originalWidth * scaledAmount) / 2" in fixed
        assert "originalHeight * scaledAmount) / 2" in fixed
        assert center_canvas(fixed) == fixed
        try:
            center_canvas("unexpected export")
        except ValueError:
            pass
        else:
            raise AssertionError("Unknown exports must fail without rewriting.")
        sample = ('<head></head><div class="container"><div class="content-line"><pre>'
                  'AGENTIC AI @ UIUC · AGENTICAIUIUC.COM   '
                  '<span style="color: orange">4</span><span style="color: gray"> / 90</span>'
                  '</pre></div></div>')
        styled = style_footer(sample)
        assert 'value="4" max="90"' in styled and '> / 90</span>' in styled
        assert '<footer class="deck-footer">' in styled
        assert styled.index('<progress ') < styled.index('class="slide-current"')
        assert 'translateY' not in styled
        assert 'href="https://agenticaiuiuc.com"' in styled
        assert style_footer(styled) == styled
        try:
            style_footer('<head></head><div class="container"></div>')
        except ValueError:
            pass
        else:
            raise AssertionError("Missing footers must fail without rewriting.")
        title_lines = ['MODULE 01', 'AGENTIC AI', 'A subtitle', 'UIUC', 'SEP 08', 'Footer', '']
        title_sample = ('<head></head><div class="container">'
                        + ''.join(f'<div class="content-line"><pre>{line}</pre></div>' for line in title_lines)
                        + '</div><div class="container">Next slide</div>')
        metadata = {'title': 'MODULE 01 · AGENTIC AI', 'sub_title': 'A subtitle',
                    'event': 'UIUC', 'date': 'SEP 08'}
        illustrated = add_title_graphic(title_sample, metadata)
        assert illustrated.count('<svg ') == 1 and '<h1>AGENTIC AI</h1>' in illustrated
        assert illustrated.endswith('<div class="container">Next slide</div>')
        assert illustrated.count('<div class="content-line">') == len(title_lines)
        assert add_title_graphic(illustrated, metadata) == illustrated
        wrapped_title = title_sample.replace('<pre>MODULE 01</pre>', '<pre>Wrapped title</pre>')
        assert '<h1>AGENTIC AI</h1>' in add_title_graphic(wrapped_title, metadata)
        print("export checks passed")
    else:
        root = Path(__file__).resolve().parent
        output = Path(sys.argv[1]) if len(sys.argv) > 1 else root / "deck.html"
        if len(sys.argv) == 1:
            subprocess.run([
                "presenterm", "-c", str(root.parent / "shared/config.yaml"),
                "-x", "--image-protocol", "ascii-blocks", "--validate-overflows",
                "--validate-snippets", "--export-html", "-o", str(output),
                "module01.md",
            ], cwd=root, check=True)
        original = output.read_text()
        source = (root / 'module01.md').read_text().split('---', 2)[1]
        metadata = {key: json.loads(re.search(rf'^{key}: (".*")$', source, re.M).group(1))
                    for key in ('title', 'sub_title', 'event', 'date')}
        updated = add_title_graphic(style_footer(center_canvas(original)), metadata)
        if updated != original:
            output.write_text(updated)
        print(output)
