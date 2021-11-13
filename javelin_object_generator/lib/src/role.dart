/// A role is a dot-separated set of names.abstract
///
/// Example:
///   user-server.client
///   platform.mobile.ios
///
/// Role rules can include a wildcard as the last element:
///   platform.mobile.*
class Role {
  Role(String role) : roleParts = role.split('.');

  final List<String> roleParts;

  /// Returns whether this role matches a [roleRule].
  ///
  /// Example:
  ///   this                  roleRule                     result
  ///   user-server.client    user-server.client           true
  ///   user-server.server    user-server.client           false
  ///   user-server           user-server.*                true
  bool matches(Role roleRule) {
    final int checkLength;

    if (roleRule.roleParts.last == '*') {
      checkLength = roleRule.roleParts.length - 1;
      if (roleParts.length < checkLength) return false;
    } else {
      checkLength = roleRule.roleParts.length;
      if (roleParts.length != checkLength) return false;
    }

    for (var i = 0; i < checkLength; ++i) {
      if (roleParts[i] != roleRule.roleParts[i]) return false;
    }
    return true;
  }

  @override
  String toString() => roleParts.toString();
}

extension RoleListExtension on List<Role> {
  bool matches(Role role) => any((rule) => role.matches(rule));
}

extension RoleStringListExtension on List<String> {
  bool matches(List<Role> rules) => any((role) => rules.matches(Role(role)));
}
