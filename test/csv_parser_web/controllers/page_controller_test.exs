defmodule FactEngineWeb.PageControllerTest do
  use FactEngineWeb.ConnCase

  @test_csv_path Application.get_env(:fact_engine, :test_csv_path)

  test "GET / - verify root id for React", %{conn: conn} do
    conn = get(conn, "/")
    assert String.contains?(html_response(conn, 200), "<div id=\"root\" />")
  end

  test "CSV Parsing Test File - Filter Email or Phone", %{conn: conn} do    
    conn = post(conn, Routes.page_path(conn, :process_csv, %{
      "strategy" => "email,phone",
      "file" => %{
        path: @test_csv_path
      }
    }))

    assert json_response(conn, 200)
    |> Enum.count() == 8
  end

  test "CSV Parsing Test File - Filter Email", %{conn: conn} do
    conn = post(conn, Routes.page_path(conn, :process_csv, %{
      "strategy" => "email",
      "file" => %{
        path: @test_csv_path
      }
    }))

    result = json_response(conn, 200)
      |> Enum.count()

    assert result == 4
  end

  test "CSV Parsing Test File - Filter Phone", %{conn: conn} do
    conn = post(conn, Routes.page_path(conn, :process_csv, %{
      "strategy" => "phone",
      "file" => %{
        path: @test_csv_path
      }
    }))

    result = json_response(conn, 200)
      |> Enum.count()

    assert result == 4
  end
end
