import yaml


def load_config(filename):
    data = {}
    with open(filename, "r", encoding="utf-8") as f:
        data = yaml.safe_load(f)
    return data
