
# Bale for Lua
Only Lua 5.3 is supported.

## Decoding
Decoding is done by applying decoding functions to streams.

A stream is anything with a `read` method supporting the *number* format as the
standard `file:read` function.

Decoding functions always return a single value when successful or nil and
a string describing the error otherwise.

### `str(s)`
Takes a string `s` and returns a stream of it's contents. The stream is a
table with a `read` function like the standard `file:read` but supporting
only the *number* format.

### `u8(s)`, `u16(s)`, `u32(s)`, `u64(s)`, `i8(s)`, `i16(s)`, `i32(s)`, `i64(s)`
Decoding functions for the bale integer types which return lua numbers
given a sufficiently long input stream.

### `f32(s)`, `f64(s)`
Decoding functions for floating-point types, these work only if the platform
native single and double precision floating point formats are from IEEE 754.

###  `uv(s)`
Decoding function for the bale variable length type.

### `tuple(...)`
This function takes as arguments alternating strings and decoding functions.

Returns a decoding function that produces a table with the strings as keys
and the results of applying the decoding functions as values.

The decoding functions are applied to the input stream in the order they are
given to the `tuple` function.

### `union(...)`
Creates a bale union decoding function, arguments should be decoding
functions for the alternatives of the union in order.

Either `none` or `nil` can be used to skip indices.

### `array(f)`
Returns a function that decodes a bale array into a lua sequence.
`f` is the decoding function for each item of the array.

### `none(s)`
Decoding function for `none`, will always return nil.

### `void(v)`
Returns a decoding function for a bale `void`. Since an empty table would
not be very useful, the value to return is specified via `v`.

### `bool(s)`
Decodes a boolean.

### `maybe(f, default)`
Returns a decoding function for an optional value. `f` is the decoding function
for the value if it is present, otherwise `default` is returned.

### `string(s)`
Decodes a string.

### `map(fk, fv)`
Returns a decoding function for a bale `map` whose keys can be decoded with
`fk` and values with `fv`.

### `n(n, f)`
Repeats the decoding function `f` `n` times and returns the result as a lua
sequence.

### `read(n)`
Returns a decoding function for a raw read of `n` bytes.

### `done(f)`
Transforms the decoding function `f` into one that returns nil if the input
stream has not been entirely consumed.

## Encoding
We encode by repeatedly applying encoding functions to an encoder and finally
calling `done` on it to retrieve the result as a string.

An encoder is a sequence of strings so you may also call `ipairs` on it to
iterate over fragments of the result.

An encoding function is a function that takes an encoder as the first argument
optionally followed by further arguments and returns the encoder it was passed.

Apart from `new` and `done`, all functions below are encoding functions which
are exported by the module as well as being available as methods of an encoder.

### `new()`
Create a new encoder.

### `e:u8(u)`, `e:u16(u)`, `e:u32(u)`, `e:u64(u)`, `e:i8(i)`, `e:i16(i)`, `e:i32(i)`, `e:i64(i)`
Encode lua signed and unsigned numbers.

### `e:f32(f)`, `e:f64(f)`
Encode floating point numbers. As with the decoding functions these rely on
the platform native format to be the right one.

### `e:uv(v)`
Encode v as a bale `uv`.

### `e:array(f, a)`
Encode a lua sequence `a` as a bale `array` by encoding each item using an
encoding function `f`.

### `e:none()`
Encode a bale `none`, this will always throw an error.

### `e:void()`
Encode a bale `void`, leaves the encoder unmodified.

### `e:bool(b)`
Encode a boolean `b`.

### `e:maybe(f, v)`
Encode `v` using the encoding function `f` if `v` is not `nil`, results in a
bale `maybe`.

### `e:map(fk, fv, m)`
Encode a lua table `m` as a bale `map` by using the encoding functions `fk` and
`fv` to encode keys and values respectively.

### `e:string(s)`
Encode a string.

### `e:n(f, a)`
Encode the sequence `a` as a fixed length tuple, encoding each item using `f`.

### `e:write(s)`
Append `s` as raw data to the encoder.

### `e:done()`
Returns the encoded data as a string.

