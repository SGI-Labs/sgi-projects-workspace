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

    def test_generate_motif_contains_expected_tokens(self):
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
            motif_out = tmp / "IRIXIDE.test.ad"
            json_out = tmp / "tokens.test.json"
            args = [
                "generate_tokens.py",
                "--source",
                str(TOKEN_JSON),
                "--motif-out",
                str(motif_out),
                "--json-out",
                str(json_out),
            ]
            with mock.patch.object(sys, "argv", args):
                gen.main()
            self.assertTrue(motif_out.exists())
            self.assertTrue(json_out.exists())
            self.assertGreater(motif_out.stat().st_size, 0)
            self.assertGreater(json_out.stat().st_size, 0)


if __name__ == "__main__":
    unittest.main()
