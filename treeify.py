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
    def __init__(self, name, parent=None, birthday=0, max_generations=10):
        if birthday > max_generations:
            raise ValueError(
                "birthday must be at most {max_generations} for this tree"
            )
        self._parent = parent
        self._name = name
        self._birthday = birthday
        self._generations = 0
        self._max_generations = max_generations
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
    def generations(self):
        return self._generations
    def add_path(self, *nodes):
        if nodes is None or len(nodes) == 0:
            return
        else:
            # Note: Using self.get(...) doesn't work, since defaultdict only
            # sets the default value on calls to __getitem__ (which is exposed
            # as indexed accessors)
            if nodes[0] not in self:
                self[nodes[0]] = Tree(
                    self._name, birthday=self._birthday + 1, parent=self,
                    max_generations=self._max_generations
                )
            self[nodes[0]].add_path(*nodes[1:])
            self._generations = max(
                self._generations, self[nodes[0]]._generations + 1
            )

if __name__ == main:
    import sys, json
    split_lines = [l.split() for l in sys.stdin]
    parsed = Tree("stdin", max_generations=30)
    for l in split_lines:
        parsed.add_path(*l)
    print(json.dumps(parsed))
