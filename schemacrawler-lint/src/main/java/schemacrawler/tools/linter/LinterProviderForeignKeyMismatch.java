/*
========================================================================
SchemaCrawler
http://www.schemacrawler.com
Copyright (c) 2000-2025, Sualeh Fatehi <sualeh@hotmail.com>.
All rights reserved.
------------------------------------------------------------------------

SchemaCrawler is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

SchemaCrawler and the accompanying materials are made available under
the terms of the Eclipse Public License v1.0, GNU General Public License
v3 or GNU Lesser General Public License v3.

You may elect to redistribute this code under any of these licenses.

The Eclipse Public License is available at:
http://www.eclipse.org/legal/epl-v10.html

The GNU General Public License v3 and the GNU Lesser General Public
License v3 are available at:
http://www.gnu.org/licenses/

========================================================================
*/

package schemacrawler.tools.linter;

import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import static java.util.Objects.requireNonNull;
import schemacrawler.schema.Column;
import schemacrawler.schema.ColumnReference;
import schemacrawler.schema.ForeignKey;
import schemacrawler.schema.Table;
import schemacrawler.schema.View;
import schemacrawler.tools.lint.BaseLinter;
import schemacrawler.tools.lint.BaseLinterProvider;
import schemacrawler.tools.lint.LintCollector;
import schemacrawler.tools.lint.LintSeverity;
import schemacrawler.tools.lint.Linter;
import us.fatehi.utility.property.PropertyName;

public class LinterProviderForeignKeyMismatch extends BaseLinterProvider {

  private static final long serialVersionUID = 7775205295917734672L;

  public LinterProviderForeignKeyMismatch() {
    super(LinterForeignKeyMismatch.class.getName());
  }

  @Override
  public Linter newLinter(final LintCollector lintCollector) {
    return new LinterForeignKeyMismatch(getPropertyName(), lintCollector);
  }
}

class LinterForeignKeyMismatch extends BaseLinter {

  LinterForeignKeyMismatch(final PropertyName linterName, final LintCollector lintCollector) {
    super(linterName, lintCollector);
    setSeverity(LintSeverity.high);
  }

  @Override
  public String getSummary() {
    return "foreign key data type different from primary key";
  }

  @Override
  protected void lint(final Table table, final Connection connections) {
    requireNonNull(table, "No table provided");

    final List<ForeignKey> mismatchedForeignKeys = findMismatchedForeignKeys(table);
    for (final ForeignKey foreignKey : mismatchedForeignKeys) {
      addTableLint(table, getSummary(), foreignKey);
    }
  }

  private List<ForeignKey> findMismatchedForeignKeys(final Table table) {
    final List<ForeignKey> mismatchedForeignKeys = new ArrayList<>();
    if (table != null && !(table instanceof View)) {
      for (final ForeignKey foreignKey : table.getImportedForeignKeys()) {
        for (final ColumnReference columnReference : foreignKey) {
          final Column pkColumn = columnReference.getPrimaryKeyColumn();
          if (!pkColumn.isColumnDataTypeKnown()) {
            continue;
          }
          final Column fkColumn = columnReference.getForeignKeyColumn();
          if (!fkColumn.isColumnDataTypeKnown()) {
            continue;
          }
          if (!pkColumn
                  .getColumnDataType()
                  .getJavaSqlType()
                  .equals(fkColumn.getColumnDataType().getJavaSqlType())
              || pkColumn.getSize() != fkColumn.getSize()) {
            mismatchedForeignKeys.add(foreignKey);
            break;
          }
        }
      }
    }
    return mismatchedForeignKeys;
  }
}
