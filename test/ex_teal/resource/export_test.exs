defmodule ExTeal.Resource.ExportTest do
  use TestExTeal.ConnCase
  alias ExTeal.Resource.Export

  defmodule CustomResource do
    use ExTeal.Resource
    import Ecto.Query
    @impl true
    def repo, do: TestExTeal.Repo
    @impl true
    def model, do: TestExTeal.Post

    @impl true
    def export_fields, do: [:id, :name]

    @impl true
    def handle_export_query(query, _conn) do
      select(query, [q], map(q, [:name, :id]))
    end
  end

  defmodule CustomExportModuleResource do
    use ExTeal.Resource
    import Ecto.Query
    @impl true
    def repo, do: TestExTeal.Repo
    @impl true
    def model, do: TestExTeal.Post

    @impl true
    def export_fields, do: [:id, :name]

    @impl true
    def handle_export_query(query, _conn) do
      select(query, [q], map(q, [:name, :id]))
    end

    @impl true
    def export_module, do: NimbleCSV.Spreadsheet
  end

  defmodule CustomRowResource do
    use ExTeal.Resource
    import Ecto.Query

    @impl true
    def repo, do: TestExTeal.Repo

    @impl true
    def model, do: TestExTeal.Post

    @impl true
    def export_fields, do: [:id, :name, :fake]

    @impl true
    def handle_export_query(query, _conn) do
      select(query, [q], map(q, [:name, :id]))
    end

    @impl true
    def parse_export_row(row, _fields) do
      [row.id, row.name, "foo"]
    end
  end

  defmodule CustomRelatedResource do
    use ExTeal.Resource
    import Ecto.Query
    alias TestExTeal.User

    @impl true
    def repo, do: TestExTeal.Repo

    @impl true
    def model, do: TestExTeal.Post

    @impl true
    def export_fields, do: [:id, :name, :email]

    @impl true
    def handle_export_query(query, _conn) do
      query
      |> join(:left, [p], u in User, on: p.user_id == u.id)
      |> select([p, u], %{id: p.id, name: p.name, email: u.email})
    end
  end

  describe "stream/2" do
    test "by default returns all records as a csv" do
      [p1, p2] = insert_pair(:post)
      conn = prep_conn(:get, "/posts/exports", %{"resources" => "all"})
      conn = Export.stream(TestExTeal.PostResource, conn)
      data = response(conn, 200)
      [header, p1_csv, p2_csv] = String.split(data, "\n", trim: true)

      assert header ==
               "id,name,body,author,contributor,published,published_at,deleted_at,features,location,user_id,inserted_at,updated_at"

      assert String.contains?(p1_csv, "#{p1.id},#{p1.name}")
      assert String.contains?(p2_csv, "#{p2.id},#{p2.name}")
    end

    test "can override the format of the export" do
      [p1, p2] = insert_pair(:post)
      conn = prep_conn(:get, "/posts/exports", %{"resources" => "all"})
      conn = Export.stream(CustomExportModuleResource, conn)
      data = response(conn, 200)

      assert data ==
               utf16le_bom() <>
                 utf16le("""
                 id\tname
                 #{p1.id}\t#{p2.name}
                 #{p2.id}\t#{p2.name}
                 """)
    end

    defp utf16le(binary), do: :unicode.characters_to_binary(binary, :utf8, {:utf16, :little})
    defp utf16le_bom, do: :unicode.encoding_to_bom({:utf16, :little})

    test "can limit to a specific set of ids" do
      [p1, _p2] = insert_pair(:post)
      conn = prep_conn(:get, "/posts/exports", %{"resources" => "#{p1.id}"})
      conn = Export.stream(TestExTeal.PostResource, conn)
      data = response(conn, 200)
      [_header, p1_csv] = String.split(data, "\n", trim: true)

      assert String.contains?(p1_csv, "#{p1.id},#{p1.name}")
    end

    test "can export the results of search" do
      u = insert(:user, name: "Bernie")
      insert(:user, name: "Donald")

      conn = prep_conn(:get, "/users/exports", %{"resources" => "all", "search" => "Bern"})
      conn = Export.stream(TestExTeal.UserResource, conn)
      data = response(conn, 200)
      [_header, u1_csv] = String.split(data, "\n", trim: true)

      assert String.contains?(u1_csv, "#{u.id}")
    end

    test "results can be sorted" do
      p1 = insert(:post, name: "Z")
      p2 = insert(:post, name: "A")

      conn =
        prep_conn(:get, "/posts/exports", %{
          "resources" => "all",
          "order_by" => "name",
          "order_by_direction" => "asc"
        })

      conn = Export.stream(TestExTeal.PostResource, conn)
      data = response(conn, 200)
      [header, p1_csv, p2_csv] = String.split(data, "\n", trim: true)

      assert header ==
               "id,name,body,author,contributor,published,published_at,deleted_at,features,location,user_id,inserted_at,updated_at"

      assert String.contains?(p1_csv, "#{p2.id},#{p2.name}")
      assert String.contains?(p2_csv, "#{p1.id},#{p1.name}")
    end

    test "can override, find and encode fields in a custom order" do
      [p1, p2] = insert_pair(:post)
      conn = prep_conn(:get, "/posts/exports", %{"resources" => "all"})
      conn = Export.stream(CustomResource, conn)
      data = response(conn, 200)
      [header, p1_csv, p2_csv] = String.split(data, "\n", trim: true)

      assert header == "id,name"
      assert p1_csv == "#{p1.id},#{p1.name}"
      assert p2_csv == "#{p2.id},#{p2.name}"
    end

    test "can customize the query to return calculated values" do
      u = insert(:user, email: "foo")
      p1 = insert(:post, user: u)
      p2 = insert(:post, user: nil)
      conn = prep_conn(:get, "/posts/exports", %{"resources" => "all"})
      conn = Export.stream(CustomRelatedResource, conn)
      data = response(conn, 200)
      [header, p1_csv, p2_csv] = String.split(data, "\n", trim: true)

      assert header == "id,name,email"
      assert p1_csv == "#{p1.id},#{p1.name},foo"
      assert p2_csv == "#{p2.id},#{p2.name},"
    end
  end

  describe "export_fields/0" do
    test "returns all fields on the schema by default" do
      fields = TestExTeal.PostResource.export_fields()

      expected =
        ~w(id name body author contributor published published_at deleted_at features location user_id inserted_at updated_at)a

      assert fields == expected
    end

    test "can be overriden" do
      assert CustomResource.export_fields() == [:id, :name]
    end
  end

  describe "default_export_fields/1" do
    test "returns the models fields based on the schema" do
      fields = TestExTeal.Post.__schema__(:fields)
      assert fields == Export.default_export_fields(TestExTeal.PostResource)
    end
  end

  describe "handle_export_query/2" do
    test "by default it selects all fields on the schema into a map" do
      conn = prep_conn(:get, "/posts/exports")
      query = TestExTeal.PostResource.handle_export_query(TestExTeal.Post, conn)
      p = insert(:post)
      [result] = Repo.all(query)

      for field <- TestExTeal.PostResource.export_fields() do
        assert Map.get(result, field) == Map.get(p, field)
      end
    end

    test "can be overriden" do
      conn = prep_conn(:get, "/posts/exports")
      query = CustomResource.handle_export_query(TestExTeal.Post, conn)
      p = insert(:post)
      [result] = Repo.all(query)

      for field <- [:id, :name] do
        assert Map.get(result, field) == Map.get(p, field)
      end
    end
  end

  describe "parse_export_row/2" do
    test "by defaults passes the row through" do
      assert [] == TestExTeal.PostResource.parse_export_row(%{}, [])
    end

    test "can be overriden to modify the row before being encoded" do
      assert [1, "foo", "foo"] == CustomRowResource.parse_export_row(%{id: 1, name: "foo"}, [])
      p1 = insert(:post)
      conn = prep_conn(:get, "/posts/exports", %{"resources" => "all"})
      conn = Export.stream(CustomRowResource, conn)
      data = response(conn, 200)
      [header, p1_csv] = String.split(data, "\n", trim: true)

      assert header == "id,name,fake"
      assert p1_csv == "#{p1.id},#{p1.name},foo"
    end
  end

  describe "default_parse/2" do
    test "returns a list of values" do
      result = Export.default_parse(%{foo: "bar", baz: true, bar: 0}, [:foo, :bar, :baz])
      assert result == ["bar", 0, true]
    end
  end

  def prep_conn(method, path, params \\ %{}) do
    params = Map.merge(params, %{"_format" => "json"})

    method
    |> build_conn(path, params)
    |> fetch_query_params()
  end
end
