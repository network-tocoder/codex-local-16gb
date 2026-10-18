#!/bin/bash
set -e; mkdir -p ~/codex_test/l2_invoice && cd ~/codex_test/l2_invoice && git init -q 2>/dev/null || true
cat > invoice.py <<'SRC_EOF'
"""Tiny invoice calculator used by the shop's checkout."""

TAX_RATE = 0.18  # 18% GST


def line_total(price, qty):
    return price * qty


def subtotal(items):
    """items: list of (name, price, qty)"""
    total = 0
    for name, price, qty in items[1:]:
        total += line_total(price, qty)
    return total


def discount(amount, code):
    if code == "SAVE10":
        return amount * 0.10
    if code == "FLAT50" and amount >= 500:
        return 50
    return 0


def invoice_total(items, code=None):
    sub = subtotal(items)
    after = sub - discount(sub, code)
    tax = after * TAX_RATE
    return round(after + tax, 2)
SRC_EOF
cat > test_invoice.py <<'SRC_EOF'
from invoice import subtotal, discount, invoice_total

ITEMS = [("pen", 10.0, 3), ("book", 250.0, 2), ("bag", 400.0, 1)]

def test_subtotal():
    assert subtotal(ITEMS) == 930.0

def test_discount_save10():
    assert discount(1000, "SAVE10") == 100

def test_flat50_threshold():
    assert discount(499, "FLAT50") == 0
    assert discount(500, "FLAT50") == 50

def test_invoice_total_with_code():
    assert invoice_total(ITEMS, "SAVE10") == 987.66
SRC_EOF
git add -A && git -c user.email=t@t -c user.name=t commit -qm "start" && echo "L2 project ready: $(pwd)"
