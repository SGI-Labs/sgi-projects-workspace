import io
import sys
import tempfile
import unittest
from unittest import mock
from contextlib import redirect_stderr
from pathlib import Path

import generate_tokens as gen

FIXTURES = Path(__file__).parent
TOKEN_JSON = FIXTURES / "tokens.sample.json"


class GenerateTokensTests(unittest.TestCase):
    def setUp(self):
        self.tokens = gen.load_tokens(TOKEN_JSON)

    def test_generate_swift_contains_expected_tokens(self):
        swift = gen.generate_swift(self.tokens)
        self.assertIn('static let bgBase', swift)
        self.assertIn('static let textPrimary', swift)
        self.assertIn('Font.custom("SF Pro Display", size: 28)', swift)

    def test_generate_motif_contains_overrides(self):
        motif = gen.generate_motif(self.tokens)
        self.assertIn('IRIXIDE*color.bg.base:            #4F5B66', motif)
        self.assertIn('IRIXIDE*spacing.s4:       12', motif)
        self.assertIn('IRIXIDE*font.heading.md', motif)

    def test_run_validations_emits_no_errors(self):
        stderr = io.StringIO()
        with redirect_stderr(stderr):
            gen.run_validations(self.tokens)
        output = stderr.getvalue()
        self.assertNotIn('[warn]', output)

    def test_main_generates_files(self):
        with tempfile.TemporaryDirectory() as tmpdir:
            tmp = Path(tmpdir)
            swift_out = tmp / "Tokens.test.swift"
            motif_out = tmp / "IRIXIDE.test.ad"
            args = [
                "generate_tokens.py",
                "--source",
                str(TOKEN_JSON),
                "--swift-out",
                str(swift_out),
                "--motif-out",
                str(motif_out),
            ]
            with mock.patch.object(sys, "argv", args):
                gen.main()
            self.assertTrue(swift_out.exists())
            self.assertTrue(motif_out.exists())
            self.assertGreater(swift_out.stat().st_size, 0)
            self.assertGreater(motif_out.stat().st_size, 0)


if __name__ == "__main__":
    unittest.main()
