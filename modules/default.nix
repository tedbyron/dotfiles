{ darwin, ... }:
{
  imports = [ (if darwin then ./darwin else ./nixos) ];
}
