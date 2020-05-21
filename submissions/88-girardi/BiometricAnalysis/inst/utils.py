"""
biosppy.utils
-------------
This module provides several frequently used functions and hacks.
:copyright: (c) 2015-2018 by Instituto de Telecomunicacoes
:license: BSD 3-clause, see LICENSE for more details.
"""

# Imports
# compat
from __future__ import absolute_import, division, print_function
from six.moves import map, range, zip
import six

# built-in

import keyword


# 3rd party
import numpy as np


def prova2(): 
    print("Hello")
    z = 3
    return(z)
    
#https://raw.githubusercontent.com/PIA-Group/BioSPPy/master/biosppy/utils.py    

class ReturnTuple(tuple):
    """A named tuple to use as a hybrid tuple-dict return object.

    Parameters
    ----------
    values : iterable
        Return values.
    names : iterable, optional
        Names for return values.

    Raises
    ------
    ValueError
        If the number of values differs from the number of names.
    ValueError
        If any of the items in names:
        * contain non-alphanumeric characters;
        * are Python keywords;
        * start with a number;
        * are duplicates.

    """

    def __new__(cls, values, names=None):

        return tuple.__new__(cls, tuple(values))

    def __init__(self, values, names=None):

        nargs = len(values)

        if names is None:
            # create names
            names = ['_%d' % i for i in range(nargs)]
        else:
            # check length
            if len(names) != nargs:
                raise ValueError("Number of names and values mismatch.")

            # convert to str
            names = list(map(str, names))

            # check for keywords, alphanumeric, digits, repeats
            seen = set()
            for name in names:
                if not all(c.isalnum() or (c == '_') for c in name):
                    raise ValueError("Names can only contain alphanumeric \
                                      characters and underscores: %r." % name)

                if keyword.iskeyword(name):
                    raise ValueError("Names cannot be a keyword: %r." % name)

                if name[0].isdigit():
                    raise ValueError("Names cannot start with a number: %r." %
                                     name)

                if name in seen:
                    raise ValueError("Encountered duplicate name: %r." % name)

                seen.add(name)

        self._names = names

    def as_dict(self):
        """Convert to an ordered dictionary.

        Returns
        -------
        out : OrderedDict
            An OrderedDict representing the return values.

        """

        return collections.OrderedDict(zip(self._names, self))

    __dict__ = property(as_dict)

    def __getitem__(self, key):
        """Get item as an index or keyword.

        Returns
        -------
        out : object
            The object corresponding to the key, if it exists.

        Raises
        ------
        KeyError
            If the key is a string and it does not exist in the mapping.
        IndexError
            If the key is an int and it is out of range.

        """

        if isinstance(key, six.string_types):
            if key not in self._names:
                raise KeyError("Unknown key: %r." % key)

            key = self._names.index(key)

        return super(ReturnTuple, self).__getitem__(key)

    def __repr__(self):
        """Return representation string."""

        tpl = '%s=%r'

        rp = ', '.join(tpl % item for item in zip(self._names, self))

        return 'ReturnTuple(%s)' % rp

    def __getnewargs__(self):
        """Return self as a plain tuple; used for copy and pickle."""

        return tuple(self)

    def keys(self):
        """Return the value names.

        Returns
        -------
        out : list
            The keys in the mapping.

        """

        return list(self._names)
