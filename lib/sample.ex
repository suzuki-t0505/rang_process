defmodule Sample do
  @path "popular-names.txt"

  # ファイル読み込みと\nでスプリットしてリストに変換する関数
  defp read_and_split(path \\ @path) do
    path
    |> File.read!()
    |> String.split("\n")
  end

  @doc """
  # 10. 行数のカウント

  行数をカウントせよ．確認にはwcコマンドを用いよ．

  ## Unix

  ```bash
  wc -l popular-names.txt
  ```

  ## Examples

  ```elixir
  iex> line_count()
  2780
  ```
  """
  def line_count() do
    length(read_and_split())
  end

  @doc """
  # 11. タブをスペースに置換

  タブ1文字につきスペース1文字に置換せよ．
  確認にはsedコマンド，trコマンド，もしくはexpandコマンドを用いよ．

  ## Unix

  ```bash
  sed 's/\t/ /' t.txt
  cat popular-names.txt | tr '\t' ' '
  expand popular-names.txt
  ```

  ## Examples

  ```elixir
  iex> replace_with_space()
  :ok
  ```
  """
  def replace_with_space() do
    @path
    |> File.read!()
    |> String.replace("\t", " ")
    #タブが含まれていないかを確認する（falseであれば含まれていない）
    # |> String.contains?("\t")
    |> IO.puts()
  end

  @doc """
  # 12. 1列目をcol1.txtに，2列目をcol2.txtに保存

  各行の1列目だけを抜き出したものをcol1.txtに，2列目だけを抜き出したものをcol2.txtとしてファイルに保存せよ．
  確認にはcutコマンドを用いよ．

  ## Unix

  ```bash
  cut -f 1 popular-names.txt > col1.txt
  cut -f 2 popular-names.txt > col2.txt
  ```

  ## Examples

  ````elixir
  iex> col_write()
  :ok
  ```
  """
  def col_write() do
    {col1, col2} =
      Enum.reduce(read_and_split(), {[], []}, & col_split/2)

    File.write("col1.txt", Enum.join(col1, "\n"))
    File.write("col2.txt", Enum.join(col2, "\n"))
  end

  defp col_split(str, {col1, col2}) do
    [c1, c2 | _] = String.split(str, "\t")

    {col1 ++ [c1], col2 ++ [c2]}
  end

  @doc """
  # 13. col1.txtとcol2.txtをマージ

  12で作ったcol1.txtとcol2.txtを結合し，元のファイルの1列目と2列目をタブ区切りで並べたテキストファイルを作成せよ．
  確認にはpasteコマンドを用いよ．

  ## Unix

  ```bash
  paste col[1-2].txt
  ```

  ## Examples

  ```elixir
  iex> col_merge()
  :ok
  ```
  """
  def col_merge() do
    ~w(col1.txt col2.txt)
    |> Enum.map(& read_and_split/1)
    |> Enum.zip()
    |> Enum.map(fn {col1, col2} -> col1 <> "\t" <> col2 end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  @doc """
  # 14. 先頭からN行を出力

  自然数Nをコマンドライン引数などの手段で受け取り，入力のうち先頭のN行だけを表示せよ．
  確認にはheadコマンドを用いよ．

  ## Unix

  ```bash
  head -n 10 popular-names.txt
  ```

  ## Examples

  引数に出力する行数を指定する

  ```elixir
  iex> head(10)
  :ok
  ```
  """
  def head(line) do
    read_and_split()
    |> Enum.slice(0..line)
    |> Enum.join("\n")
    |> IO.puts()
  end

  @doc """
  ## 15. 末尾のN行を出力

  自然数Nをコマンドライン引数などの手段で受け取り，入力のうち末尾のN行だけを表示せよ．
  確認にはtailコマンドを用いよ．

  ## Unix

  ```bash
  tail -n 10 popular-names.txt
  ```

  ## Examples

  引数に出力する行数を指定する

  ```elixir
  iex> tail(10)
  :ok
  ```
  """
  def tail(line) do
    read_and_split()
    |> Enum.slice(-line..-1)
    |> Enum.join("\n")
    |> IO.puts()
  end

  @doc """
  # 16. ファイルをN分割する

  自然数Nをコマンドライン引数などの手段で受け取り，入力のファイルを行単位でN分割せよ．同様の処理をsplitコマンドで実現せよ．

  ※splitコマンドはファイル出力をするコマンドなので指定した行ごとにファイルに書き込みを行っている

  ### Unix

  ```bash
  split -l 10 -d --additional-suffix=.txt popular-names.txt
  ```

  ## Examples

  引数に分ける行数を指定する

  ※引数の値が小さいと大量にファイルが生成される

  ```elixir
  iex> split(100)
  :ok
  ```
  """
  def split(line) do
    read_and_split()
    |> Enum.chunk_every(line)
    |> Enum.with_index(0)
    |> Enum.each(fn {chunk, index} ->
      chunk
      |> Enum.join("\n")
      |> then(fn str -> File.write("split-#{index}.txt", str) end)
    end)
  end

  @doc """
  # 17. １列目の文字列の異なり

  1列目の文字列の種類（異なる文字列の集合）を求めよ．確認にはcut, sort, uniqコマンドを用いよ．

  ## Unix

  ```bash
  cut -f 1 popular-names.txt | sort | uniq
  ```

  ## Examples

  ````elixir
  iex> diff()
  :ok
  ```
  """
  def diff() do
    read_and_split()
    |> Enum.map(fn str ->
      str
      |> String.split("\t")
      |> hd()
    end)
    |> Enum.sort()
    |> Enum.uniq()
    |> Enum.join("\n")
    |> IO.puts()
  end

  @doc """
  # 18. 各行を3コラム目の数値の降順にソート

  各行を3コラム目の数値の逆順で整列せよ（注意: 各行の内容は変更せずに並び替えよ）．
  確認にはsortコマンドを用いよ（この問題はコマンドで実行した時の結果と合わなくてもよい）．

  ## Unix

  ```bash
  sort -r -n -k 3 popular-names.txt
  ```

  ## Examples

  ````elixir
  iex> col_sort()
  :ok
  ```
  """
  def col_sort() do
    read_and_split()
    |> Enum.map(fn str -> String.split(str, "\t") end)
    |> Enum.sort(fn [_, _, prev, _], [_, _, next, _] ->
      String.to_integer(prev) > String.to_integer(next)
    end)
    |> Enum.map(fn list -> Enum.join(list, "\t") end)
    |> Enum.join("\n")
    |> IO.puts()
  end

  @doc """
  # 19. 各行の1コラム目の文字列の出現頻度を求め，出現頻度の高い順に並べる

  各行の1列目の文字列の出現頻度を求め，その高い順に並べて表示せよ．
  確認にはcut, uniq, sortコマンドを用いよ．

  ## Unix

  ```bash
  cut -f 1 popular-names.txt | sort | uniq -c | sort -r -n  -k 1
  ```

  ## Examples

  ```elixir
  iex> frequency()
  :ok
  ```
  """
  def frequency() do
    read_and_split()
    |> Enum.map(fn str ->
      str
      |> String.split("\t")
      |> hd()
    end)
    |> Enum.frequencies()
    |> Enum.sort_by(fn {_col, count} -> count end, :desc)
    |> Enum.map(fn {col, count} -> "#{count} #{col}" end)
    |> Enum.join("\n")
    |> IO.puts()
  end
end
