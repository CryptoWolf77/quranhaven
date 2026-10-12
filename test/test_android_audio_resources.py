"""Guard dynamically resolved audio controls against Android resource shrinking."""

from pathlib import Path
import unittest
import xml.etree.ElementTree as ET


class AndroidAudioResourcesTests(unittest.TestCase):
    def test_release_keeps_launcher_and_dynamic_audio_service_drawables(self):
        root = Path(__file__).resolve().parents[1]
        resources = ET.parse(root / "android/app/src/main/res/raw/keep.xml").getroot()
        retained = resources.attrib["{http://schemas.android.com/tools}keep"].split(",")
        self.assertIn("@mipmap/ic_launcher", retained)
        self.assertIn("@drawable/audio_service_*", retained)


if __name__ == "__main__":
    unittest.main()
