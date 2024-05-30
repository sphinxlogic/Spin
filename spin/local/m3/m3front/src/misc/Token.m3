(* Copyright (C) 1992, Digital Equipment Corporation           *)
(* All rights reserved.                                        *)
(* See the file COPYRIGHT for a full description.              *)

(* File: Token.m3                                              *)
(* Last modified on Tue Dec 20 10:37:51 PST 1994 by kalsow     *)
(*      modified on Sat Mar 16 00:31:12 1991 by muller         *)

(*
 * HISTORY
 * 23-May-96  Wilson Hsieh (whsieh) at the University of Washington
 *	added T.tFUNCTIONAL
 *
 * 03-Mar-96  Wilson Hsieh (whsieh) at the University of Washington
 *	added T.tALIGNED
 *
 * 14-Jan-96  Wilson Hsieh (whsieh) at the University of Washington
 *	support for CVAR
 *
 * 08-Jan-96  Wilson Hsieh (whsieh) at the University of Washington
 *	support for IMPLICIT exceptions
 *
 * 25-Oct-95  Wilson Hsieh (whsieh) at the University of Washington
 *	support for bounded
 *
 *)

MODULE Token;

IMPORT M3ID;

CONST
  Keywords = ARRAY T OF TEXT { 
    "*EOF*",

    "*id*", "*cardinal*", "*real*", "*longreal*",
    "*extended*", "*char*", "*text*",

    "+", "-", "*", "/", ":=", "&", ".", ",",
    ";", "(", "[", "{", "^", "=", "#", "<",
    ">", "<=", ">=", "..", ":", ")", "]",
    "}", "|", "<:", "=>", "*>",

    "INLINE", "EXTERNAL", "ASSERT", "UNUSED", "OBSOLETE", "TRACE",
    "*CALLCONV*", "FATAL", "IMPLICIT",

    "AND", "ALIGNED", "ANY", "ARRAY", "AS",
    "BEGIN", "BITS",
    "BRANDED", "BY",
    "CASE", "CONST",
    "CVAR",
    "DIV", "DO",
    "ELSE", "ELSIF", "END", 
    "EPHEMERAL",
    "EVAL", "EXCEPT", "EXCEPTION", "EXIT", "EXPORTS",
    "FINALLY", "FOR", "FROM", "FUNCTIONAL",
    "GENERIC",
    "IF", "IMPORT", "IN", "INTERFACE",
    "LOCK", "LOOP",
    "METHODS", "MOD", "MODULE",
    "NOT",
    "OBJECT", "OF", "OR", "OVERRIDES",
    "PROCEDURE",
    "RAISE", "RAISES", "READONLY", "RECORD", "REF", "REPEAT","RETURN","REVEAL",
    "SET",
    "THEN", "TO", "TRY", "TYPE", "TYPECASE",
    "UNSAFE", "UNTIL", "UNTRACED",
    "VALUE", "VAR",
    "WHILE", "WITH"
  };

  Reserved = ARRAY OF TEXT {
    "ABS", "ADDRESS", "ADR", "ADRSIZE", "BITSIZE", "BOOLEAN",
    "BYTESIZE", "CARDINAL", "CEILING", "CHAR", "DEC", "DISPOSE",
    "EXTENDED", "FALSE", "FIRST", "FLOAT", "FLOOR", "INC",
    "INTEGER", "ISTYPE", "LAST", "LONGREAL", "LOOPHOLE", "MAX",
    "MIN", "MUTEX", "NARROW", "NEW", "NIL", "NULL", "NUMBER",
    "ORD", "REAL", "REFANY", "ROOT", "ROUND", "SUBARRAY", "TEXT",
    "TRUE", "TRUNC", "TYPECODE", "VAL"
  };

  (* spin specific reserved keywords *)
  Spin = ARRAY OF TEXT {
  (*
    (* reclamation support *)
    "RECLAIM", "RECLAIMABLE", "RECLAIMED",  "USING", 
  *)
    (* generic procedure type *)
    "PROCANY",
    (* casting of bytes support *)
    "VIEW",
    (* runtime representation of modules and interfaces. *)
    "INTERFACE_UNIT", "THIS_MODULE"
  };

PROCEDURE Initialize () =
  (* Make sure that the keywords and reserved identifiers get
     assigned small M3ID.Ts.  Otherwise, the tables indexed by ID in
     Scanner will overflow. *)
  BEGIN
    FOR t := FIRST (T) TO LAST (T) DO
      name[t] := M3ID.Add (Keywords[t], ORD (t));
    END;
    FOR i := FIRST (Reserved) TO LAST (Reserved) DO
      EVAL M3ID.Add (Reserved[i]);
    END;

    (* Add the SPIN specific reserved words here *)
    FOR i := FIRST (Spin) TO LAST (Spin) DO
      EVAL M3ID.Add (Spin[i]);
    END;

  END Initialize;

BEGIN
END Token.