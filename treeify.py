#!/bin/env python
"""
Tree class and helper functions to parse a config file consisting of simple
commands of the form
    <cmd> [<subcmds...] [<args>...]
into a tree in which each parsed command corresponds to exactly one path from
the root to a leaf node.
Use case: Assisting the creation of clean template files for config files of
potentially unmanageable length and / or complexity
"""
class Tree(dict):
    def __init__(self, name, parent=None, birthday=0, max_depth=10,
            joiner=' '.join):
        if birthday > max_depth:
            raise ValueError(
                f"birthday must be at most {max_depth} for this tree"
            )
        self._joiner = joiner
        self._parent = parent
        self._name = name
        self._birthday = birthday
        self._depth = 0
        self._max_depth = max_depth
    @property
    def max_depth(self):
        return self._max_depth
    @property
    def parent(self):
        return self._parent
    @property
    def name(self):
        return self._name
    @property
    def birthday(self):
        return self._birthday
    @property
    def depth(self):
        return self._depth
    def join(self):
        # Should this be handled with jq instead?
        pass
    def add_child(self, elem):
        self[elem] = Tree(
            self._name, birthday=self._birthday + 1, parent=self,
            max_depth=self._max_depth, joiner=self._joiner
        )
    def add_path(self, *nodes):
        if nodes is None or len(nodes) == 0:
            # Throw exception?
            return
        elif self.birthday >= self.max_depth:
            self[self._joiner(nodes)] = None
        else:
            if nodes[0] not in self:
                self.add_child(nodes[0])
            self[nodes[0]].add_path(*nodes[1:])
            self._depth = max(
                self._depth, self[nodes[0]]._depth + 1
            )

if __name__ == "__main__":
    import sys, json
    split_lines = [l.split() for l in sys.stdin]
    parsed = Tree("stdin", max_depth=2)
    for l in split_lines:
        parsed.add_path(*l)
    print(json.dumps(parsed))
