def FlagsForFile( filename, **kwargs ):
   return {
     'flags': [
         '-x', 'c', '-Wall', '-Wextra', '-Werror', '-std=c11',
         '-isystem', '/usr/include',
         '-isystem', '/usr/local/include',
         '-I.'
         ],
   }
