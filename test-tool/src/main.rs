use std::path::PathBuf;

use clap::Parser;

#[derive(Debug, Parser)]
struct Cli {
    test_name: String,
}

fn main() {
    env_logger::try_init().unwrap();

    let cli = Cli::parse();

    let gold_path = PathBuf::from(format!(
        "rbx-test-files/models/{}/binary.rbxm",
        cli.test_name
    ));
    let luau_path = PathBuf::from(format!("tests/output/{}.rbxm", cli.test_name));

    let gold_file = fs_err::read(&gold_path).unwrap();
    let luau_file = fs_err::read(&luau_path).unwrap();

    eprintln!("Reading Gold file {}", cli.test_name);
    let gold_dom = rbx_binary::text_format::DecodedModel::from_reader(gold_file.as_slice());
    eprintln!("Reading Luau file {}", cli.test_name);
    let luau_dom = rbx_binary::text_format::DecodedModel::from_reader(luau_file.as_slice());

    let mut settings = insta::Settings::new();
    settings.set_omit_expression(false);
    settings.set_prepend_module_to_snapshot(false);
    settings.set_snapshot_path("../../tests/snapshots");
    settings.bind(|| {
        let test_name = format!("{}-encode", cli.test_name);
        insta::assert_yaml_snapshot!(test_name.as_str(), gold_dom);
        insta::assert_yaml_snapshot!(test_name.as_str(), luau_dom);
    })
}
