import os
import re

color_map = {
    r"const Color\(0xFFF6F6F9\)": "Theme.of(context).scaffoldBackgroundColor",
    r"Color\(0xFFF6F6F9\)": "Theme.of(context).scaffoldBackgroundColor",
    r"Colors\.white": "Theme.of(context).cardColor",
    r"const Color\(0xFF1B1B2F\)": "Theme.of(context).colorScheme.onSurface",
    r"Color\(0xFF1B1B2F\)": "Theme.of(context).colorScheme.onSurface",
    r"const Color\(0xFF7A7A90\)": "Theme.of(context).colorScheme.onSurfaceVariant",
    r"Color\(0xFF7A7A90\)": "Theme.of(context).colorScheme.onSurfaceVariant",
    r"const Color\(0xFFEAEAEE\)": "Theme.of(context).dividerColor",
    r"Color\(0xFFEAEAEE\)": "Theme.of(context).dividerColor",
    r"const Color\(0xFFF3F3F6\)": "Theme.of(context).dividerColor",
    r"Color\(0xFFF3F3F6\)": "Theme.of(context).dividerColor",
    r"const Color\(0xFFC4C4CD\)": "Theme.of(context).disabledColor",
    r"Color\(0xFFC4C4CD\)": "Theme.of(context).disabledColor",
    r"const Color\(0xFFE4C9FF\)": "Theme.of(context).colorScheme.primaryContainer",
    r"Color\(0xFFE4C9FF\)": "Theme.of(context).colorScheme.primaryContainer",
    r"const Color\(0xFFF0E0FF\)": "Theme.of(context).colorScheme.secondaryContainer",
    r"Color\(0xFFF0E0FF\)": "Theme.of(context).colorScheme.secondaryContainer",
    r"const Color\(0xFF7C3AED\)": "Theme.of(context).colorScheme.primary",
    r"Color\(0xFF7C3AED\)": "Theme.of(context).colorScheme.primary",
    r"const Color\(0xFF8EE0A5\)": "Theme.of(context).colorScheme.secondary",
    r"Color\(0xFF8EE0A5\)": "Theme.of(context).colorScheme.secondary",
    r"const Color\(0xFF1E1E2E\)": "Theme.of(context).cardColor",
    r"Color\(0xFF1E1E2E\)": "Theme.of(context).cardColor",
    r"const Color\(0xFFF3EDFF\)": "Theme.of(context).colorScheme.primary.withOpacity(0.1)",
    r"Color\(0xFFF3EDFF\)": "Theme.of(context).colorScheme.primary.withOpacity(0.1)",
    r"const Color\(0xFFE8FBF2\)": "Theme.of(context).colorScheme.secondary.withOpacity(0.1)",
    r"Color\(0xFFE8FBF2\)": "Theme.of(context).colorScheme.secondary.withOpacity(0.1)",
    r"const Color\(0xFFB5B5C3\)": "Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)",
    r"Color\(0xFFB5B5C3\)": "Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.6)",
}

def clean_file(path):
    if "main.dart" in path: return # We will update main.dart manually

    with open(path, 'r', encoding='utf-8') as f:
        code = f.read()

    targets = [
        'Text', 'TextStyle', 'Color', 'SizedBox', 'Padding', 'Icon',
        'BoxDecoration', 'EdgeInsets', 'Column', 'Row', 'Center',
        'BorderRadius', 'OutlineInputBorder', 'ThemeData', 'ColorScheme',
        'LinearGradient', 'BoxShadow', 'Offset', 'Scaffold', 'Container', 
        'Divider', 'FlTitlesData', 'SideTitles', 'AxisTitles', 'FlGridData', 
        'FlLine', 'FlBorderData', 'BarChartGroupData', 'BarChartRodData', 
        'ValueKey', 'CircularNotchedRectangle', 'CircularProgressIndicator', 
        'Expanded', 'Positioned', 'SafeArea', 'SingleChildScrollView', 'Stack'
    ]
    for t in targets:
        code = re.sub(r'\bconst\s+' + t + r'\b', t, code)
        
    code = re.sub(r'const\s+\[', r'[', code)
    code = re.sub(r'const\s+\{', r'{', code)
    
    for pattern, repl in color_map.items():
        code = re.sub(pattern, repl, code)
        
    with open(path, 'w', encoding='utf-8') as f:
        f.write(code)

for root, _, files in os.walk('lib'):
    for file in files:
        if file.endswith('.dart'):
            clean_file(os.path.join(root, file))

print("DONE")
