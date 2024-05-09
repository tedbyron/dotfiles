{ isDarwin, ... }:
{
  imports = [ (if isDarwin then ./darwin else ./nixos) ];
}
