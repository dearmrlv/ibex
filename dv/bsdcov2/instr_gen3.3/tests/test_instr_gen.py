from __future__ import annotations

import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "scripts"))

from _coverage import improves, parse_report, write_curve_csv, write_curve_svg
from _formal import emit_formal_imem
from _image import (GENERATED_START, append_candidate, candidate_signature,
                    generated_words, write_image)


class ImageTests(unittest.TestCase):
    def test_append_is_contiguous(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            initial = root / "initial.bin"
            initial.write_bytes(bytes(GENERATED_START - 0x80000000))
            base = root / "base.bin"
            write_image(initial, [], base)
            output = root / "output.bin"
            append_candidate(base, [(GENERATED_START, 0x00000013),
                                    (GENERATED_START + 4, 0x00100093)], output)
            self.assertEqual(len(generated_words(output)), 2)
            self.assertEqual(candidate_signature([(GENERATED_START, 1)]),
                             candidate_signature([(GENERATED_START, 1)]))
            with self.assertRaises(RuntimeError):
                append_candidate(base, [(GENERATED_START + 4, 0)], root / "bad.bin")

    def test_formal_imem_has_fixed_and_symbolic_ranges(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            image = root / "image.bin"
            image.write_bytes(bytes(GENERATED_START - 0x80000000) +
                              (0x00000013).to_bytes(4, "little"))
            output = root / "imem.sv"
            emit_formal_imem(image, output, 8)
            text = output.read_text()
            self.assertIn("SYMBOLIC_WORDS = 8", text)
            self.assertIn("32'h80000120: fixed_lookup = 32'h00000013", text)
            self.assertIn("32'h80000124", text)


class CoverageTests(unittest.TestCase):
    def test_parse_and_improvement(self) -> None:
        report = """Legend: x
name Block* Covered Branch* Covered Statement* Covered Expression* Covered Toggle* Covered Statement* Covered Fsm* Covered Assertion* Covered CoverGroup* Covered
ibex_top 10.00% (1/10) 20.00% (2/10) 30.00% (3/10) 40.00% (4/10) 50.00% (5/10) 30.00% (3/10) 60.00% (6/10) 90.00% (9/10) 70.00% (7/10)
"""
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "report.txt"
            path.write_text(report)
            old = parse_report(path)
            self.assertEqual(old["covergroup"]["covered"], 7)
            new = {key: dict(value) for key, value in old.items()}
            new["branch"]["covered"] = 3
            gain, delta = improves(old, new)
            self.assertTrue(gain)
            self.assertEqual(delta["branch"], 1)

    def test_write_curve_outputs(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            row = {"accepted_iteration": 0, "bin_instruction_count": 40,
                   "image_word_count": 72, "generated_word_count": 0,
                   "retired_instruction_count": 40, "property": "baseline"}
            for metric in ("block", "branch", "statement", "expression",
                           "toggle", "fsm", "covergroup"):
                row[f"{metric}_covered"] = 1
                row[f"{metric}_total"] = 2
                row[f"{metric}_percent"] = 50.0
            write_curve_csv(root / "curve.csv", [row])
            write_curve_svg(root / "curve.svg", [row], "unit")
            self.assertIn("bin_instruction_count", (root / "curve.csv").read_text())
            self.assertIn("<svg", (root / "curve.svg").read_text())


if __name__ == "__main__":
    unittest.main()
