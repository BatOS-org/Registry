# Builds the catalog.json for the app from all app files:
#   nix eval --json .#catalog > catalog.json
{ lib, apps, appDirs, rev }:
let
  required = [ "name" "description" "config" ];

  checkFields = id: app:
    let missing = lib.filter (f: !(app ? ${f})) required; in
    if missing == [ ] then app
    else throw "meineapp: App '${id}' fehlt: ${lib.concatStringsSep ", " missing}";

  # Output literalExpression/literalMD as text, so that everything can be generated as JSON.
  plain = v:
    if lib.isAttrs v && v ? _type && v ? text then v.text else v;

  # Depending on the nixpkgs version, the value list of types.enum lives
  # in functor.payload.values (new) or directly in functor.payload (old).
  enumValues = type:
    let payload = type.functor.payload or null; in
    payload.values or payload;

  setting = opt: {
    type        = opt.type.name;          # "bool", "str", "enum", "listOf", ...
    typeText    = opt.type.description;   # "boolean", "string", ...
    default     = plain (opt.default or null);
    example     = plain (opt.example or null);
    description = plain (opt.description or "");
  }
  // lib.optionalAttrs (opt.type.name == "enum") { values = enumValues opt.type; }
  // lib.optionalAttrs (opt.type.nestedTypes ? elemType) { elemType = opt.type.nestedTypes.elemType.name; };

  # Content of a file in the app folder as text, or null if it is missing.
  readOptional = dir: file:
    let f = dir + "/${file}"; in
    if builtins.pathExists f then builtins.readFile f else null;
in
{
  version = rev;   # commit ID, for matching against flake.lock
  apps = lib.mapAttrs (id: app0:
    let
      app = checkFields id app0;
      dir = appDirs.${id};
    in
    {
      inherit (app) name description;
      category = app.category or "Sonstiges";
      keywords = app.keywords or [ ];
      settings = lib.mapAttrs (_: setting) (app.settings or { });
      readme   = readOptional dir "README.md";
      # Only SVG can be inlined: builtins.readFile cannot read binary files like PNG.
      iconSvg  = readOptional dir "icon.svg";
    }) apps;
}
